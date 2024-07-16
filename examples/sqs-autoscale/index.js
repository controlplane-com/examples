const { SQSClient, GetQueueAttributesCommand } = require("@aws-sdk/client-sqs");
const fs = require("fs");
const { execSync } = require("child_process");

// Load the JSON array
const data = JSON.parse(fs.readFileSync("config.json", "utf8"));

var awsRegion = process.env.AWS_REGION;

// Ensure AWS_REGION environment variable is set
if (!awsRegion) {
  console.error(
    "Error: AWS_REGION environment variable is not set. Using 'us-west-2'"
  );
  awsRegion = "us-west-2";
}

// Configure AWS SDK client
const client = new SQSClient({ region: awsRegion });

data.forEach(async (item) => {
  const params = {
    QueueUrl: item.sqsEndpoint,
    AttributeNames: ["ApproximateNumberOfMessages"],
  };

  try {
    const command = new GetQueueAttributesCommand(params);
    const result = await client.send(command);
    const queueSize = parseInt(
      result.Attributes.ApproximateNumberOfMessages,
      10
    );
    console.log(
      `Queue for workload ${item.workloadName} has ${queueSize} messages.`
    );

    // Find the rule with the highest length that is less than or equal to the queue size
    const applicableRule = item.scalingRules
      .filter((rule) => queueSize >= rule.length)
      .reduce(
        (maxRule, currentRule) => {
          return currentRule.length > maxRule.length ? currentRule : maxRule;
        },
        { length: -1, scaleAmount: 0 }
      );

    console.log(
      `Applicable Length: ${applicableRule.length} - Applicable Rule: ${applicableRule.scaleAmount}`
    );

    if (applicableRule.length >= 0) {
      try {
        console.log(
          `Scaling ${item.gvc}/${item.workloadName} by ${applicableRule.scaleAmount}`
        );

        // Perform your scaling logic here

        // Fetch the workload as a JSON object through cpln
        const workload = JSON.parse(
          execSync(
            `cpln workload get ${item.workloadName} -o json --gvc ${item.gvc}`
          ).toString()
        );

        workload.spec.defaultOptions.autoscaling.minScale = `${applicableRule.scaleAmount}`;
        workload.spec.defaultOptions.autoscaling.maxScale = `${applicableRule.scaleAmount}`;

        const response = execSync(
          `echo '${JSON.stringify(workload)}' | cpln apply --gvc ${
            item.gvc
          } --file -`
        ).toString();

        console.log(`Response from cpln: ${response}`);
      } catch (err) {
        console.error(
          `Error in scaling logic for workload ${item.workloadName}:`,
          err
        );
      }
    } else {
      console.log(
        `No applicable scaling rule found for workload ${item.workloadName} with queue size ${queueSize}.`
      );
    }
  } catch (err) {
    console.error(
      `Error fetching queue attributes for workload ${item.workloadName}:`,
      err
    );
  }
});
