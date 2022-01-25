package aws

import (
	"context"
	"errors"
	elb "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
	"github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2/types"
	"github.com/aws/smithy-go/middleware"
)

type MockElbApi struct {
	StaticIpAddresses          []string
	FailToRegisterTargets      bool
	FailToDeregisterTargets    bool
	FailToDescribeTargetHealth bool
}

func (m MockElbApi) RegisterTargets(ctx context.Context, params *elb.RegisterTargetsInput, optFns ...func(*elb.Options)) (*elb.RegisterTargetsOutput, error) {
	if m.FailToRegisterTargets {
		return nil, errors.New("failed to register targets")
	}

	return nil, nil
}

func (m MockElbApi) DeregisterTargets(ctx context.Context, params *elb.DeregisterTargetsInput, optFns ...func(*elb.Options)) (*elb.DeregisterTargetsOutput, error) {
	if m.FailToDeregisterTargets {
		return nil, errors.New("failed to de-register targets")
	}

	return nil, nil
}

func (m MockElbApi) DescribeTargetHealth(ctx context.Context, params *elb.DescribeTargetHealthInput, optFns ...func(*elb.Options)) (*elb.DescribeTargetHealthOutput, error) {
	if m.FailToDescribeTargetHealth {
		return nil, errors.New("arbitrary failure")
	}
	var t []types.TargetHealthDescription
	for _, ip := range m.StaticIpAddresses {
		t = append(t, types.TargetHealthDescription{
			Target: &types.TargetDescription{
				Id: &ip,
			},
		})
	}
	return &elb.DescribeTargetHealthOutput{
		TargetHealthDescriptions: t,
		ResultMetadata:           middleware.Metadata{},
	}, nil
}
