package nlb_management

import (
	"errors"
)

type MockCloudServiceProvider struct {
	CurrentState             ManagedLoadBalancer
	DesiredState             ManagedLoadBalancer
	FailDiscoverCurrentState bool
	FailDiscoverDesiredState bool
	FailRegisterTargets      bool
	FailDeRegisterTargets    bool
}

func (csp MockCloudServiceProvider) DiscoverCurrentState(m *ManagedLoadBalancer) error {
	if csp.FailDiscoverCurrentState {
		return errors.New("arbitrary failure")
	}
	m.TargetGroups = csp.CurrentState.TargetGroups
	return nil
}

func (csp MockCloudServiceProvider) DiscoverDesiredState(m *ManagedLoadBalancer) error {
	if csp.FailDiscoverDesiredState {
		return errors.New("arbitrary failure")
	}
	m.TargetGroups = csp.DesiredState.TargetGroups
	return nil
}

func (csp MockCloudServiceProvider) DeRegisterTargets(m *ManagedLoadBalancer) error {
	if csp.FailDeRegisterTargets {
		return errors.New("arbitrary failure")
	}
	return nil
}

func (csp MockCloudServiceProvider) RegisterTargets(m *ManagedLoadBalancer) error {
	if csp.FailRegisterTargets {
		return errors.New("arbitrary failure")
	}
	return nil
}
