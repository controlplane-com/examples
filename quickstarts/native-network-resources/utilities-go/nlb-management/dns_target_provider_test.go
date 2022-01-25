package nlb_management

import (
	"reflect"
	"testing"
)

func TestCreate(t *testing.T) {
	type args struct {
		cloudServiceProvider ICloudServiceProvider
		targetsToManage      ManagedLoadBalancer
	}
	tests := []struct {
		name    string
		args    args
		want    *DnsTargetProvider
		wantErr bool
	}{
		{
			"missing-cloud-service-provider",
			args{
				nil,
				ManagedLoadBalancer{},
			},
			nil,
			true,
		},
		{
			"empty-mlb-name",
			args{
				MockCloudServiceProvider{},
				ManagedLoadBalancer{},
			},
			nil,
			true,
		},
		{
			"valid-mlb",
			args{
				MockCloudServiceProvider{
					CurrentState: ManagedLoadBalancer{
						TargetGroups: map[string]*DnsTargetGroup{
							"tg-0:arn": {
								FQDN: "some-fqdn.com",
								IpAddresses: []string{
									"192.168.0.0",
								},
							},
						},
					},
				},
				ManagedLoadBalancer{
					Name: "mlb-0",
				},
			},
			&DnsTargetProvider{
				LoadBalancer: ManagedLoadBalancer{
					Name: "mlb-0",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
							},
						},
					},
				},
				cloudServiceProvider: MockCloudServiceProvider{
					CurrentState: ManagedLoadBalancer{
						TargetGroups: map[string]*DnsTargetGroup{
							"tg-0:arn": {
								FQDN: "some-fqdn.com",
								IpAddresses: []string{
									"192.168.0.0",
								},
							},
						},
					},
				},
			},
			false,
		},
		{
			"fail-to-discover-current-state",
			args{
				MockCloudServiceProvider{
					CurrentState:             ManagedLoadBalancer{},
					FailDiscoverCurrentState: true,
				},
				ManagedLoadBalancer{
					Name: "mlb-0",
				},
			},
			&DnsTargetProvider{
				LoadBalancer: ManagedLoadBalancer{
					Name:         "mlb-0",
					TargetGroups: map[string]*DnsTargetGroup{},
				},
				cloudServiceProvider: MockCloudServiceProvider{
					CurrentState: ManagedLoadBalancer{},
				},
			},
			true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := Create(tt.args.cloudServiceProvider, tt.args.targetsToManage)
			if (err != nil) != tt.wantErr {
				t.Errorf("Create() error = %v, wantErr %v", err, tt.wantErr)
			}
			if err != nil && tt.wantErr {
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("Create() got = %v, wantToDeRegister %v", got, tt.want)
			}
		})
	}
}

func TestDnsTargetProvider_Copy(t1 *testing.T) {
	type fields struct {
		LoadBalancer         ManagedLoadBalancer
		cloudServiceProvider ICloudServiceProvider
	}
	tests := []struct {
		name    string
		fields  fields
		want    *DnsTargetProvider
		wantErr bool
	}{
		{
			"copy-one-tg",
			fields{
				ManagedLoadBalancer{
					Name: "mlb-0",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							"some-fqdn.com",
							[]string{
								"192.168.0.0",
							},
						},
					},
				},
				MockCloudServiceProvider{},
			},
			&DnsTargetProvider{
				cloudServiceProvider: MockCloudServiceProvider{},
				LoadBalancer: ManagedLoadBalancer{
					Name: "mlb-0",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							"some-fqdn.com",
							[]string{
								"192.168.0.0",
							},
						},
					},
				},
			},
			false,
		},
		{
			"tg-with-nil-ip-addresses",
			fields{
				ManagedLoadBalancer{
					Name: "mlb-0",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
						},
					},
				},
				MockCloudServiceProvider{},
			},
			&DnsTargetProvider{
				cloudServiceProvider: MockCloudServiceProvider{},
				LoadBalancer: ManagedLoadBalancer{
					Name: "mlb-0",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
						},
					},
				},
			},
			false,
		},
		{
			"copy-multiple-tgs",
			fields{
				ManagedLoadBalancer{
					Name: "mlb-0",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							"some-fqdn.com",
							[]string{
								"192.168.0.0",
							},
						},
						"tg-1": {
							"some-other-fqdn.com",
							[]string{
								"192.168.0.1",
							},
						},
					},
				},
				MockCloudServiceProvider{},
			},
			&DnsTargetProvider{
				cloudServiceProvider: MockCloudServiceProvider{},
				LoadBalancer: ManagedLoadBalancer{
					Name: "mlb-0",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							"some-fqdn.com",
							[]string{
								"192.168.0.0",
							},
						},
						"tg-1": {
							"some-other-fqdn.com",
							[]string{
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
		t1.Run(tt.name, func(t1 *testing.T) {
			t := DnsTargetProvider{
				cloudServiceProvider: tt.fields.cloudServiceProvider,
				LoadBalancer:         tt.fields.LoadBalancer,
			}
			if got := t.Copy(); !reflect.DeepEqual(got, tt.want) {
				t1.Errorf("Copy() = %v, wantToDeRegister %v", got, tt.want)
			}
		})
	}
}

func TestDnsTargetProvider_RefreshIpAddresses(t1 *testing.T) {
	type fields struct {
		LoadBalancer         ManagedLoadBalancer
		cloudServiceProvider ICloudServiceProvider
	}
	tests := []struct {
		name    string
		fields  fields
		wantErr bool
	}{
		{
			name: "fail-to-discover-desired-state",
			fields: fields{
				LoadBalancer:         ManagedLoadBalancer{},
				cloudServiceProvider: MockCloudServiceProvider{FailDiscoverDesiredState: true},
			},
			wantErr: true,
		},
		{
			name: "fail-to-de-register-targets",
			fields: fields{
				LoadBalancer:         ManagedLoadBalancer{},
				cloudServiceProvider: MockCloudServiceProvider{FailDeRegisterTargets: true},
			},
			wantErr: true,
		},
		{
			name: "fail-to-de-register-targets",
			fields: fields{
				LoadBalancer:         ManagedLoadBalancer{},
				cloudServiceProvider: MockCloudServiceProvider{FailRegisterTargets: true},
			},
			wantErr: true,
		},
		{
			name: "success",
			fields: fields{
				LoadBalancer:         ManagedLoadBalancer{},
				cloudServiceProvider: MockCloudServiceProvider{},
			},
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t1.Run(tt.name, func(t1 *testing.T) {
			t := DnsTargetProvider{
				LoadBalancer:         tt.fields.LoadBalancer,
				cloudServiceProvider: tt.fields.cloudServiceProvider,
			}
			if err := t.RefreshIpAddresses(); (err != nil) != tt.wantErr {
				t1.Errorf("RefreshIpAddresses() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func Test_findTargetGroupChanges(t *testing.T) {
	type args struct {
		currentState ManagedLoadBalancer
		desiredState ManagedLoadBalancer
	}
	tests := []struct {
		name             string
		args             args
		wantToDeRegister *ManagedLoadBalancer
		wantToRegister   *ManagedLoadBalancer
	}{
		{
			name: "one-added-one-removed",
			args: args{
				currentState: ManagedLoadBalancer{
					Name: "current-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.1",
							},
						},
					},
				},
				desiredState: ManagedLoadBalancer{
					Name: "desired-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.2",
							},
						},
					},
				},
			},
			wantToDeRegister: &ManagedLoadBalancer{
				Name: "desired-state",
				TargetGroups: map[string]*DnsTargetGroup{
					"tg-0:arn": {
						FQDN: "some-fqdn.com",
						IpAddresses: []string{
							"192.168.0.1",
						},
					},
				},
			},
			wantToRegister: &ManagedLoadBalancer{
				Name: "current-state",
				TargetGroups: map[string]*DnsTargetGroup{
					"tg-0:arn": {
						FQDN: "some-fqdn.com",
						IpAddresses: []string{
							"192.168.0.2",
						},
					},
				},
			},
		},
		{
			name: "one-removed",
			args: args{
				currentState: ManagedLoadBalancer{
					Name: "current-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.1",
							},
						},
					},
				},
				desiredState: ManagedLoadBalancer{
					Name: "desired-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
							},
						},
					},
				},
			},
			wantToDeRegister: &ManagedLoadBalancer{
				Name: "desired-state",
				TargetGroups: map[string]*DnsTargetGroup{
					"tg-0:arn": {
						FQDN: "some-fqdn.com",
						IpAddresses: []string{
							"192.168.0.1",
						},
					},
				},
			},
			wantToRegister: &ManagedLoadBalancer{
				Name:         "current-state",
				TargetGroups: map[string]*DnsTargetGroup{},
			},
		},
		{
			name: "one-added",
			args: args{
				currentState: ManagedLoadBalancer{
					Name: "current-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
							},
						},
					},
				},
				desiredState: ManagedLoadBalancer{
					Name: "desired-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.2",
							},
						},
					},
				},
			},
			wantToDeRegister: &ManagedLoadBalancer{
				Name:         "desired-state",
				TargetGroups: map[string]*DnsTargetGroup{},
			},
			wantToRegister: &ManagedLoadBalancer{
				Name: "current-state",
				TargetGroups: map[string]*DnsTargetGroup{
					"tg-0:arn": {
						FQDN: "some-fqdn.com",
						IpAddresses: []string{
							"192.168.0.2",
						},
					},
				},
			},
		},
		{
			name: "no-changes",
			args: args{
				currentState: ManagedLoadBalancer{
					Name: "current-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
							},
						},
					},
				},
				desiredState: ManagedLoadBalancer{
					Name: "desired-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
							},
						},
					},
				},
			},
			wantToDeRegister: &ManagedLoadBalancer{
				Name:         "desired-state",
				TargetGroups: map[string]*DnsTargetGroup{},
			},
			wantToRegister: &ManagedLoadBalancer{
				Name:         "current-state",
				TargetGroups: map[string]*DnsTargetGroup{},
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, got1 := findTargetGroupChanges(tt.args.currentState, tt.args.desiredState)
			if !reflect.DeepEqual(got, tt.wantToDeRegister) {
				t.Errorf("findTargetGroupChanges() got = %v, wantToDeRegister %v", got, tt.wantToDeRegister)
			}
			if !reflect.DeepEqual(got1, tt.wantToRegister) {
				t.Errorf("findTargetGroupChanges() got1 = %v, wantToDeRegister %v", got1, tt.wantToRegister)
			}
		})
	}
}

func Test_targetGroupDiff(t *testing.T) {
	type args struct {
		tg1 ManagedLoadBalancer
		tg2 ManagedLoadBalancer
	}
	tests := []struct {
		name string
		args args
		want *ManagedLoadBalancer
	}{
		{
			name: "no-diff",
			args: args{
				tg1: ManagedLoadBalancer{
					Name: "current-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
							},
						},
					},
				},
				tg2: ManagedLoadBalancer{
					Name: "desired-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
							},
						},
					},
				},
			},
			want: &ManagedLoadBalancer{
				Name:         "desired-state",
				TargetGroups: map[string]*DnsTargetGroup{},
			},
		},
		{
			name: "one-ip-address-removed",
			args: args{
				tg1: ManagedLoadBalancer{
					Name: "current-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.1",
							},
						},
					},
				},
				tg2: ManagedLoadBalancer{
					Name: "desired-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
							},
						},
					},
				},
			},
			want: &ManagedLoadBalancer{
				Name: "desired-state",
				TargetGroups: map[string]*DnsTargetGroup{
					"tg-0:arn": {
						FQDN: "some-fqdn.com",
						IpAddresses: []string{
							"192.168.0.1",
						},
					},
				},
			},
		},
		{
			name: "multiple-ip-addresses-removed",
			args: args{
				tg1: ManagedLoadBalancer{
					Name: "current-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.1",
								"192.168.0.2",
							},
						},
					},
				},
				tg2: ManagedLoadBalancer{
					Name: "desired-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
							},
						},
					},
				},
			},
			want: &ManagedLoadBalancer{
				Name: "desired-state",
				TargetGroups: map[string]*DnsTargetGroup{
					"tg-0:arn": {
						FQDN: "some-fqdn.com",
						IpAddresses: []string{
							"192.168.0.1",
							"192.168.0.2",
						},
					},
				},
			},
		},
		{
			name: "entire-tg-missing",
			args: args{
				tg1: ManagedLoadBalancer{
					Name: "current-state",
					TargetGroups: map[string]*DnsTargetGroup{
						"tg-0:arn": {
							FQDN: "some-fqdn.com",
							IpAddresses: []string{
								"192.168.0.0",
								"192.168.0.1",
								"192.168.0.2",
							},
						},
					},
				},
				tg2: ManagedLoadBalancer{
					Name:         "desired-state",
					TargetGroups: map[string]*DnsTargetGroup{},
				},
			},
			want: &ManagedLoadBalancer{
				Name:         "desired-state",
				TargetGroups: map[string]*DnsTargetGroup{},
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := targetGroupDiff(tt.args.tg1, tt.args.tg2); !reflect.DeepEqual(got, tt.want) {
				t.Errorf("targetGroupDiff() = %v, wantToDeRegister %v", got, tt.want)
			}
		})
	}
}
