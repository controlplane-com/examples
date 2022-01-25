package aws

import "context"
import elb "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"

type IElbApi interface {
	RegisterTargets(ctx context.Context, params *elb.RegisterTargetsInput, optFns ...func(*elb.Options)) (*elb.RegisterTargetsOutput, error)
	DeregisterTargets(ctx context.Context, params *elb.DeregisterTargetsInput, optFns ...func(*elb.Options)) (*elb.DeregisterTargetsOutput, error)
	DescribeTargetHealth(ctx context.Context, params *elb.DescribeTargetHealthInput, optFns ...func(*elb.Options)) (*elb.DescribeTargetHealthOutput, error)
}
