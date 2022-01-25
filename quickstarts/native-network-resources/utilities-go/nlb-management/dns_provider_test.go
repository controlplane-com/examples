package nlb_management

import (
	"net"
	"testing"
)

func TestDefaultDnsProvider_LookupIP(t *testing.T) {
	type args struct {
		fqdn string
	}
	tests := []struct {
		name    string
		args    args
		want    []net.IP
		wantErr bool
	}{
		{
			"invalid-name",
			args{
				fqdn: "notadnsname$",
			},
			[]net.IP{},
			true,
		},
		{
			"invalid-name",
			args{
				fqdn: "www.google.com",
			},
			[]net.IP{},
			false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			d := DefaultDnsProvider{}
			got, err := d.LookupIP(tt.args.fqdn)
			if (err != nil) != tt.wantErr {
				t.Errorf("LookupIP() error = %v, wantErr %v", err, tt.wantErr)
				return
			} else if !tt.wantErr && len(got) == 0 {
				t.Errorf("LookupIP() got = %v, want %v", got, tt.want)
			}
		})
	}
}
