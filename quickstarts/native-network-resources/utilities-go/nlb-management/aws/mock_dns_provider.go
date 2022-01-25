package aws

import (
	"errors"
	"net"
	"regexp"
)

type MockDnsProvider struct {
	StaticIpAddresses []string
	validFQDNRegex    *regexp.Regexp
}

func CreateMockDnsProvider(staticIpAddresses []string) *MockDnsProvider {
	r, _ := regexp.Compile("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$")
	return &MockDnsProvider{
		validFQDNRegex:    r,
		StaticIpAddresses: staticIpAddresses,
	}
}

func (m MockDnsProvider) LookupIP(fqdn string) ([]net.IP, error) {
	if !m.validFQDNRegex.MatchString(fqdn) {
		return nil, errors.New("the given fqdn is invalid (" + fqdn + ")")
	}
	ips := make([]net.IP, len(m.StaticIpAddresses))
	for i := 0; i < len(m.StaticIpAddresses); i++ {
		ip := net.IP{}
		ip.UnmarshalText([]byte(m.StaticIpAddresses[i]))
		ips[i] = ip
	}
	return ips, nil
}
