package main

import (
	"context"
	n "cpln/nlb-management"
	"cpln/nlb-management/aws"
	"encoding/json"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	elb "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
	"log"
)

func HandleRequest(ctx context.Context, balancer n.ManagedLoadBalancer) (string, error) {
	eventJson, _ := json.MarshalIndent(balancer, "", " ")
	log.Printf("Started. Received:\n%s\n", eventJson)
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return "Something went wrong while loading the default AWS configuration", err
	}

	cloudServiceProvider, err := aws.Create(elb.NewFromConfig(cfg), n.DefaultDnsProvider{}, ctx)
	if err != nil {
		return "Something went wrong while creating the cloud service provider", err
	}

	dnsTargetProvider, err := n.Create(cloudServiceProvider, balancer)
	if err != nil {
		return "Something went wrong while creating the DnsTargetProvider", err
	}

	err = dnsTargetProvider.RefreshIpAddresses()
	if err != nil {
		return "Something went wrong while refreshing the NLB IP addresses", err
	}

	log.Println("NLB IP addresses refreshed successfully")
	return "NLB IP addresses refreshed successfully", nil
}

func main() {
	lambda.Start(HandleRequest)
}
