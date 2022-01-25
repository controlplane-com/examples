package nlb_management

type ICloudServiceProvider interface {
	DiscoverCurrentState(m *ManagedLoadBalancer) error
	DiscoverDesiredState(m *ManagedLoadBalancer) error
	DeRegisterTargets(m *ManagedLoadBalancer) error
	RegisterTargets(m *ManagedLoadBalancer) error
}
