package aws

import (
	"context"
	n "cpln/nlb-management"
	"reflect"
	"testing"
)

func TestCloudServiceProvider_DeRegisterTargets(t *testing.T) {
	type fields struct {
		elbApi      IElbApi
		dnsProvider n.IDnsProvider
		ctx         context.Context
	}
	type args struct {
		m *n.ManagedLoadBalancer
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		wantErr bool
	}{
		{
			"missing-elb-api",
			fields{},
			args{
				&n.ManagedLoadBalancer{
					Name:         "",
					TargetGroups: map[string]*n.DnsTargetGroup{},
				},
			},
			true,
		},
		{
			"missing-mlb",
			fields{
				MockElbApi{},
				nil,
				context.TODO(),
			},
			args{
				nil,
			},
			true,
		},
		{
			"de-registration-failure",
			fields{
				MockElbApi{FailToDeregisterTargets: true},
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.1",
							},
						},
					},
				},
			},
			true,
		},
		{
			"de-registration-success",
			fields{
				MockElbApi{FailToDeregisterTargets: false},
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.1",
							},
						},
					},
				},
			},
			false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			a := CloudServiceProvider{
				elbApi:      tt.fields.elbApi,
				dnsProvider: tt.fields.dnsProvider,
				ctx:         tt.fields.ctx,
			}
			if err := a.DeRegisterTargets(tt.args.m); (err != nil) != tt.wantErr {
				t.Errorf("DeRegisterTargets() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestCloudServiceProvider_DiscoverCurrentState(t *testing.T) {
	type fields struct {
		elbApi      IElbApi
		dnsProvider n.IDnsProvider
		ctx         context.Context
	}
	type args struct {
		m *n.ManagedLoadBalancer
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		wantErr bool
	}{
		{
			"multiple-ip-addresses",
			fields{
				MockElbApi{
					StaticIpAddresses: []string{
						"192.168.0.0",
						"192.168.0.1",
					},
				},
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			false,
		},
		{
			"single-ip-address",
			fields{
				MockElbApi{
					StaticIpAddresses: []string{
						"192.168.0.0",
					}},
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			false,
		},
		{
			"multiple-ip-addresses-multiple-tgs",
			fields{
				MockElbApi{
					StaticIpAddresses: []string{
						"192.168.0.0",
						"192.168.0.1",
					}},
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
						"tg-1": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			false,
		},
		{
			"single-ip-address-single-tg",
			fields{
				MockElbApi{
					StaticIpAddresses: []string{
						"192.168.0.0",
					}},
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
						"tg-1": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			false,
		},
		{
			"missing-mlb",
			fields{
				MockElbApi{
					StaticIpAddresses: []string{
						"192.168.0.0",
					}},
				nil,
				context.TODO(),
			},
			args{
				nil,
			},
			true,
		},
		{
			"missing-elb-api",
			fields{
				nil,
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			true,
		},
		{
			"discover-health-failure",
			fields{
				MockElbApi{
					StaticIpAddresses: []string{
						"192.168.0.0",
					},
					FailToDescribeTargetHealth: true,
				},
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			a := CloudServiceProvider{
				elbApi:      tt.fields.elbApi,
				dnsProvider: tt.fields.dnsProvider,
				ctx:         tt.fields.ctx,
			}
			if err := a.DiscoverCurrentState(tt.args.m); (err != nil) != tt.wantErr {
				t.Errorf("DiscoverCurrentState() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func validateDiscoverDesiredStateResults(t *testing.T, d n.IDnsProvider, lb *n.ManagedLoadBalancer) {
	if lb == nil || d == nil {
		return
	}
	m := d.(*MockDnsProvider)
	for _, tg := range lb.TargetGroups {
		actualLength := len(tg.IpAddresses)
		desiredLength := len(m.StaticIpAddresses)
		if actualLength != desiredLength {
			t.Fatalf("Expected %d ip addresses after DiscoverDesiredState, got %d", desiredLength, actualLength)
		}
		for i := 0; i < len(m.StaticIpAddresses); i++ {
			if tg.IpAddresses[i] != m.StaticIpAddresses[i] {
				t.Fatalf("Expected ip address \"%s\" at index %d, got \"%s\"", m.StaticIpAddresses[i], i, lb.TargetGroups["test"].IpAddresses[i])
			}
		}
	}
}

func TestCloudServiceProvider_DiscoverDesiredState(t *testing.T) {
	type fields struct {
		elbApi      IElbApi
		dnsProvider n.IDnsProvider
		ctx         context.Context
	}
	type args struct {
		m *n.ManagedLoadBalancer
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		wantErr bool
	}{
		{
			"zero-ip-addresses",
			fields{
				nil,
				CreateMockDnsProvider([]string{}),
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			false,
		},
		{
			"missing-mlb",
			fields{
				nil,
				CreateMockDnsProvider([]string{}),
				context.TODO(),
			},
			args{},
			true,
		},
		{
			"missing-dns-provider",
			fields{
				nil,
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			true,
		},
		{
			"invalid-fqdn",
			fields{
				nil,
				CreateMockDnsProvider([]string{}),
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "-some-invalid-fqdn",
						},
					},
				},
			},
			true,
		},
		{
			"multiple-ip-addresses",
			fields{
				MockElbApi{},
				CreateMockDnsProvider([]string{
					"192.168.0.0",
					"192.168.0.1",
				}),
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			false,
		},
		{
			"single-ip-address",
			fields{
				MockElbApi{},
				CreateMockDnsProvider([]string{
					"192.168.0.0",
				}),
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			false,
		},
		{
			"multiple-ip-addresses-multiple-tgs",
			fields{
				MockElbApi{},
				CreateMockDnsProvider([]string{
					"192.168.0.0",
					"192.168.0.1",
				}),
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
						"tg-1": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			false,
		},
		{
			"single-ip-address-single-tg",
			fields{
				MockElbApi{},
				CreateMockDnsProvider([]string{
					"192.168.0.0",
				}),
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "test",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
						},
						"tg-1": {
							FQDN: "some-fqdn",
						},
					},
				},
			},
			false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			a := CloudServiceProvider{
				elbApi:      tt.fields.elbApi,
				dnsProvider: tt.fields.dnsProvider,
				ctx:         tt.fields.ctx,
			}
			if err := a.DiscoverDesiredState(tt.args.m); (err != nil) != tt.wantErr {
				t.Errorf("DiscoverDesiredState() error = %v, wantErr %v", err, tt.wantErr)
			}
			validateDiscoverDesiredStateResults(t, tt.fields.dnsProvider, tt.args.m)
		})
	}
}

func TestCloudServiceProvider_RegisterTargets(t *testing.T) {
	type fields struct {
		elbApi      IElbApi
		dnsProvider n.IDnsProvider
		ctx         context.Context
	}
	type args struct {
		m *n.ManagedLoadBalancer
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		wantErr bool
	}{
		{
			"missing-elb-api",
			fields{},
			args{
				&n.ManagedLoadBalancer{
					Name:         "",
					TargetGroups: map[string]*n.DnsTargetGroup{},
				},
			},
			true,
		},
		{
			"missing-mlb",
			fields{
				MockElbApi{},
				nil,
				context.TODO(),
			},
			args{
				nil,
			},
			true,
		},
		{
			"registration-failure",
			fields{
				MockElbApi{FailToRegisterTargets: true},
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.1",
							},
						},
					},
				},
			},
			true,
		},
		{
			"registration-success",
			fields{
				MockElbApi{FailToRegisterTargets: false},
				nil,
				context.TODO(),
			},
			args{
				&n.ManagedLoadBalancer{
					Name: "",
					TargetGroups: map[string]*n.DnsTargetGroup{
						"tg-0": {
							FQDN: "some-fqdn",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.1",
							},
						},
					},
				},
			},
			false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			a := CloudServiceProvider{
				elbApi:      tt.fields.elbApi,
				dnsProvider: tt.fields.dnsProvider,
				ctx:         tt.fields.ctx,
			}
			if err := a.RegisterTargets(tt.args.m); (err != nil) != tt.wantErr {
				t.Errorf("RegisterTargets() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestCreate(t *testing.T) {
	type args struct {
		elbApi      IElbApi
		dnsProvider n.IDnsProvider
		ctx         context.Context
	}
	tests := []struct {
		name    string
		args    args
		want    n.ICloudServiceProvider
		wantErr bool
	}{
		{
			"missing-everything",
			args{},
			nil,
			true,
		},
		{
			"missing-elb-api",
			args{
				nil,
				MockDnsProvider{},
				context.TODO(),
			},
			nil,
			true,
		},
		{
			"missing-dns-provider",
			args{
				MockElbApi{},
				nil,
				context.TODO(),
			},
			nil,
			true,
		},
		{
			"successful-create",
			args{
				MockElbApi{},
				MockDnsProvider{},
				context.TODO(),
			},
			CloudServiceProvider{
				elbApi:      MockElbApi{},
				dnsProvider: MockDnsProvider{},
				ctx:         context.TODO(),
			},
			false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := Create(tt.args.elbApi, tt.args.dnsProvider, tt.args.ctx)
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("Create() = %v, want %v", got, tt.want)
			}

			if (err != nil) != tt.wantErr {
				t.Errorf("RegisterTargets() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
