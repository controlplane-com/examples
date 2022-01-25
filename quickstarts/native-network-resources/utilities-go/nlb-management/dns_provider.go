package nlb_management

import "net"

type IDnsProvider interface {
	LookupIP(fqdn string) ([]net.IP, error)
}

type DefaultDnsProvider struct {
}

func (d DefaultDnsProvider) LookupIP(fqdn string) ([]net.IP, error) {
	return net.LookupIP(fqdn)
}
