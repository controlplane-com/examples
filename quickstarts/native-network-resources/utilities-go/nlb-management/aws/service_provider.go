package aws

import (
	"context"
	n "cpln/nlb-management"
	"errors"
	elb "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
	"github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2/types"
	"log"
)

type CloudServiceProvider struct {
	elbApi      IElbApi
	dnsProvider n.IDnsProvider
	ctx         context.Context
}

func Create(elbApi IElbApi, dnsProvider n.IDnsProvider, ctx context.Context) (n.ICloudServiceProvider, error) {
	if elbApi == nil {
		return nil, errors.New("missing required argument elbApi")
	}
	if dnsProvider == nil {
		return nil, errors.New("missing required argument dnsProvider")
	}

	return CloudServiceProvider{
		elbApi:      elbApi,
		dnsProvider: dnsProvider,
		ctx:         ctx,
	}, nil
}

func (a CloudServiceProvider) DiscoverDesiredState(m *n.ManagedLoadBalancer) error {
	if a.dnsProvider == nil {
		return errors.New("no IDnsProvider implementation was provided")
	}
	if m == nil {
		return errors.New("invalid argument. A nil *n.ManagedLoadBalancer was given")
	}
	for _, tg := range m.TargetGroups {
		tg.IpAddresses = make([]string, 0)
		ips, err := a.dnsProvider.LookupIP(tg.FQDN)
		if err != nil {
			return err
		}
		for _, ip := range ips {
			tg.IpAddresses = append(tg.IpAddresses, ip.String())
		}
	}
	return nil
}

func (a CloudServiceProvider) DiscoverCurrentState(m *n.ManagedLoadBalancer) error {
	if a.elbApi == nil {
		return errors.New("no IElbApi implementation was provided")
	}
	if m == nil {
		return errors.New("invalid argument. A nil *n.ManagedLoadBalancer was given")
	}
	for tgName, tg := range m.TargetGroups {
		log.Printf("DiscoverCurrentState: calling DescribeTargetHealth for %s\n", tgName)
		tg.IpAddresses = make([]string, 0)
		describeTargetHealthOutput, err := a.elbApi.DescribeTargetHealth(a.ctx, &elb.DescribeTargetHealthInput{
			TargetGroupArn: &tgName,
		})
		if err != nil {
			return err
		}
		for _, tHealth := range describeTargetHealthOutput.TargetHealthDescriptions {
			tg.IpAddresses = append(tg.IpAddresses, *tHealth.Target.Id)
		}
	}
	return nil
}

func (a CloudServiceProvider) DeRegisterTargets(m *n.ManagedLoadBalancer) error {
	if a.elbApi == (IElbApi)(nil) {
		return errors.New("no IElbApi implementation was provided")
	}
	if m == nil {
		return errors.New("invalid argument. A nil *n.ManagedLoadBalancer was given")
	}
	for tgArn, tg := range m.TargetGroups {
		targetDescriptions := make([]types.TargetDescription, len(tg.IpAddresses))
		for i, ip := range tg.IpAddresses {
			targetDescriptions[i] = types.TargetDescription{
				Id: &ip,
			}
		}
		_, err := a.elbApi.DeregisterTargets(a.ctx, &elb.DeregisterTargetsInput{
			TargetGroupArn: &tgArn,
			Targets:        targetDescriptions,
		})
		if err != nil {
			return err
		}
	}
	return nil
}

func (a CloudServiceProvider) RegisterTargets(m *n.ManagedLoadBalancer) error {
	if a.elbApi == (IElbApi)(nil) {
		return errors.New("no IElbApi implementation was provided")
	}
	if m == nil {
		return errors.New("invalid argument. A nil *n.ManagedLoadBalancer was given")
	}
	for tgArn, tg := range m.TargetGroups {
		targetDescriptions := make([]types.TargetDescription, len(tg.IpAddresses))
		for i, ip := range tg.IpAddresses {
			targetDescriptions[i] = types.TargetDescription{Id: &ip}
		}
		_, err := a.elbApi.RegisterTargets(a.ctx, &elb.RegisterTargetsInput{
			Targets:        targetDescriptions,
			TargetGroupArn: &tgArn,
		})
		if err != nil {
			return err
		}
	}
	return nil
}
