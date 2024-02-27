import express from "express";
import { execSync } from "child_process";

// Define a port to listen to for incoming HTTP requests
const port = 3000;

// Initialize a new express application
const app = express();

// Define a route handler for GET requests on the root URL '/'
app.get("/", (req, res) => {
  // Setup info
  const about = {
    Version: process.env.CPLN_WORKLOAD_VERSION,
    GlobalEndpoint: process.env.CPLN_GLOBAL_ENDPOINT,
    Locations: process.env.CPLN_LOCATION,
    Image: process.env.CPLN_IMAGE,
    SelfLink: process.env.CPLN_WORKLOAD,
  };

  // TIP: For more build-in environment variables, visit the following URL:
  // https://docs.controlplane.com/reference/workload#built-in-env

  // Send the about as a response
  res.send(JSON.stringify(about));
});

// Create a GET route handler for the '/update-min-scale' URL
app.get("/update-min-scale", (req, res) => {
  // Extract the workload name from the self link of the workload
  const workloadName = getLastSegment(process.env.CPLN_WORKLOAD);

  // Fetch the workload as a JSON object through cpln
  const workload = JSON.parse(
    execSync(`cpln workload get ${workloadName} -o json`).toString()
  );

  // Update the min scale value of the workload object with a random number
  const originalMinScale = workload.spec.defaultOptions.autoscaling.minScale;
  workload.spec.defaultOptions.autoscaling.minScale = getRandomNumber(
    1,
    8,
    originalMinScale
  );

  // Apply the changes by providing the workload as an stdin input to the apply command
  const response = execSync(
    `echo '${JSON.stringify(workload)}' | cpln apply --file -`
  ).toString();

  // Send the response of the apply command to the client
  res.send(response);
});

// Start the server listening on the specified port
app.listen(port, () => {
  console.log(`Server is running on port: ${port}`);
});

/*** Functions ***/
/**
 * Gets the last segment from a path.
 * @param {string} path - The input string representing a path with segments.
 * @returns {string} The last segment of the given path.
 */
function getLastSegment(path) {
  // Split the input string into an array of segments based on the '/' delimiter.
  const segments = path.split("/");

  // The last element in the segments array is the segment after the final '/'
  return segments[segments.length - 1];
}

/**
 * Generates a random whole number within a specified range.
 *
 * @param {number} min - The minimum value of the range (inclusive).
 * @param {number} max - The maximum value of the range (inclusive).
 * @param {number} exclude - The number to exclude from the random results.
 * @returns {number} - A random number between min and max, excluding the specified number.
 */
function getRandomNumber(min, max, exclude) {
  // Validate input: min should be less than max.
  if (min >= max) throw new Error("Min should be less than max");

  let randomNum;
  do {
    // Generate a random number in the specified range.
    randomNum = Math.floor(Math.random() * (max - min + 1)) + min;
  } while (randomNum === exclude); // Repeat if the random number is equal to the excluded value.

  return randomNum;
}
