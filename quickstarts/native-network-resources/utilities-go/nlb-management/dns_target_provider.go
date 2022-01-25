package nlb_management

import (
	"errors"
	"fmt"
	"log"
	"strings"
)

type DnsTargetProvider struct {
	LoadBalancer         ManagedLoadBalancer
	cloudServiceProvider ICloudServiceProvider
}

type ManagedLoadBalancer struct {
	Name         string
	TargetGroups map[string]*DnsTargetGroup
}

func (m *ManagedLoadBalancer) GetIpAddressesForTargetGroup(targetGroupName string) []string {
	if tg, ok := m.TargetGroups[targetGroupName]; ok {
		return tg.IpAddresses
	}
	return []string{}
}

type DnsTargetGroup struct {
	FQDN        string
	IpAddresses []string
}

func Create(cloudServiceProvider ICloudServiceProvider, managedLoadBalancer ManagedLoadBalancer) (*DnsTargetProvider, error) {
	if cloudServiceProvider == nil {
		return nil, errors.New("invalid arguments. A ICloudServiceProvider was not passed")
	}
	if managedLoadBalancer.Name == "" {
		return nil, errors.New("invalid arguments. A non-empty name is required in the given ManagedLoadBalancer")
	}
	err := cloudServiceProvider.DiscoverCurrentState(&managedLoadBalancer)
	if err != nil {
		return nil, err
	}
	dtp := &DnsTargetProvider{
		LoadBalancer:         managedLoadBalancer,
		cloudServiceProvider: cloudServiceProvider,
	}
	return dtp, nil
}

func (t *DnsTargetProvider) Copy() *DnsTargetProvider {
	copiedLoadBalancer := ManagedLoadBalancer{
		Name:         t.LoadBalancer.Name,
		TargetGroups: map[string]*DnsTargetGroup{},
	}
	for tgName, tg := range t.LoadBalancer.TargetGroups {
		copiedTg := DnsTargetGroup{
			FQDN:        tg.FQDN,
			IpAddresses: tg.IpAddresses,
		}
		copiedLoadBalancer.TargetGroups[tgName] = &copiedTg
	}
	return &DnsTargetProvider{
		cloudServiceProvider: t.cloudServiceProvider,
		LoadBalancer:         copiedLoadBalancer,
	}
}

func (t *DnsTargetProvider) RefreshIpAddresses() error {
	desiredState := t.Copy()
	err := t.cloudServiceProvider.DiscoverDesiredState(&desiredState.LoadBalancer)
	if err != nil {
		return err
	}

	toDeRegister, toRegister := findTargetGroupChanges(t.LoadBalancer, desiredState.LoadBalancer)
	err = t.cloudServiceProvider.DeRegisterTargets(toDeRegister)
	if err != nil {
		return err
	}

	err = t.cloudServiceProvider.RegisterTargets(toRegister)
	if err != nil {
		return err
	}

	return nil
}

func findTargetGroupChanges(currentState ManagedLoadBalancer, desiredState ManagedLoadBalancer) (*ManagedLoadBalancer, *ManagedLoadBalancer) {
	toDeRegister := targetGroupDiff(currentState, desiredState)
	toRegister := targetGroupDiff(desiredState, currentState)
	printTargetGroupChangeLogSummary(&currentState, toDeRegister, toRegister)
	return toDeRegister, toRegister
}

func printTargetGroupChangeLogSummary(currentState *ManagedLoadBalancer, toDeRegister *ManagedLoadBalancer, toRegister *ManagedLoadBalancer) {
	if len(currentState.TargetGroups) == 0 {
		log.Println("No changes detected in any target group.")
	}
	for tgName, tg := range currentState.TargetGroups {
		tgLogMessage := fmt.Sprintf("\n%s\n%s\nFQDN: %s\n", tgName, strings.Repeat("-", len(tgName)), tg.FQDN)
		ipsToDeRegister := toDeRegister.GetIpAddressesForTargetGroup(tgName)
		ipsToRegister := toRegister.GetIpAddressesForTargetGroup(tgName)
		if len(ipsToDeRegister) != 0 {
			tgLogMessage += fmt.Sprintf("De-registering:\n[%s]\n", strings.Join(ipsToDeRegister, ", "))
		}
		if len(ipsToRegister) != 0 {
			tgLogMessage += fmt.Sprintf("Registering:[%s]\n", strings.Join(ipsToRegister, ", "))
		}
		if len(ipsToDeRegister) == 0 && len(ipsToRegister) == 0 {
			tgLogMessage += "No changes detected\n"
		}
		log.Println(tgLogMessage)
	}
}

func targetGroupDiff(mlb1 ManagedLoadBalancer, mlb2 ManagedLoadBalancer) *ManagedLoadBalancer {
	mtg := &ManagedLoadBalancer{
		Name:         mlb2.Name,
		TargetGroups: map[string]*DnsTargetGroup{},
	}
	for name, tg1 := range mlb1.TargetGroups {
		tg2, exists := mlb2.TargetGroups[name]
		if !exists {
			continue
		}

		for _, pip := range tg1.IpAddresses {
			found := false
			for _, cip := range tg2.IpAddresses {
				if cip == pip {
					found = true
				}
			}
			if !found {
				if _, exists := mtg.TargetGroups[name]; !exists {
					mtg.TargetGroups[name] = &DnsTargetGroup{
						FQDN: tg2.FQDN,
					}
				}
				tg := mtg.TargetGroups[name]
				tg.IpAddresses = append(mtg.TargetGroups[name].IpAddresses, pip)
			}
		}
	}
	return mtg
}
