# Prerequisites

- The `cpln` [CLI](https://docs.controlplane.com/reference/cli#installation)

- A `cpln` [profile](https://docs.controlplane.com/guides/manage-profile) with access to the billing account you wish to query.

- Postman

# Configuring Your Postman Environment

1. Import the collection and the environment from this example.

2. Retrieve your account id from the ["Org Management & Billing" page](https://console.cpln.io/billing/account) in the [Control Plane Console](https://console.cpln.io)
   
3. In a terminal, run the following command: `cpln profile token --jwt`. Most of the time you can use your default profile. If you have multiple profiles configured, make sure you enable the one with access to the billing account you wish to query.

   - The command will output an Authorization header. Take the JWT and save it in the "Example" postman environment in the variable `cplnTokenServerToken`. The token will begin with `eyJh`

4. Set `profile` to the name of your profile (usually, this is `default`)

5. In a terminal run `cpln profile token --serve`. This will run a secure HTTP server on port 43200, which serves dynamic tokens to the pre-request scripts in this collection.

# Concepts

## Consumptions

Consumptions (as the name suggests) record how much of a certain resource you have consumed while using Control Plane. Each consumption has:

- `value`

    - The raw value consumed. The units of this value vary, depending on the `tags`. In the example below, the value is in bytes.

- `total`

    - The monetary charges attached to the consumption.

- `tags`

    - These are key/value pairs which uniquely identify and categories the consumed resource. In the example below, the tags identify this consumption as the total egress for all workloads in the org `some-org`, within control-plane-hosted locations.


For example:

``` json
{
  "total": 11.494142071,
  "currency": "USD",
  "ratePlans": [
    "289ebdde-e39c-497f-9a24-b17db3ab8a68"
  ],
  "value": 102847842272,
  "tags": {
    "feature": "workloads",
    "locationType": "control_plane_hosted",
    "metric": "egress",
    "org": "some-org"
  }
}

 ```

## Chargeable Items

Not all consumptions are chargeable, and some chargeable items have a price dependent on a tag's value (e.g. the price
of a volume depends on the value of the `performanceClass` tag.) To get a full picture of your pending charges, you'll 
need to query the billing API using every unique combination of tags returned from the "List Chargable Items" request in
this collection.

# Querying Charges

Use the "Query Charges By..." requests to see quick query examples. Query fields:

- `startTime`/ `endTime`

    - The start and end _**time**_ of your billing query. Note that if you choose a day e.g. `2024-01-15`, you have chosen that day _**at midnight**_. Querying for charges between `2024-01-01` and `2024-01-15`, will give you the first 14 days of the month.

    - To select a whole month, use the first of the following month as the `endTime`. For example, `2024-01-01` - `2024-02-01` will give you the whole month of January 2024.

    - This is done for two main reasons:

        - It is easy to write queries generically for any month, without knowing how many days are in the month.

        - We avoid needing to write silly things like `2024-01-15T23:59:59` to get the "whole" 15th

    - **NOTE:** billing is done in UTC time. This means that day, week, and month boundaries are according to UTC.

- `timeStep` (`month`, `week`, `day`, or `hour`)

    - Consumptions are stored discreetly, aggregated by one of these `timeStep` values.

    - The start/end times will be expanded to the nearest time step boundary if necessary. e.g. if you specify a one-day window, but select `month` as the `timeStep`, you will receive data for the whole month containing the given day.

- `aggregateByTimeStep`(bool)

    - If this is false, the charges will be summed across the given time window, rather than by each time step contained therein.

    - If for example you choose a `timeStep` of day, but select `2024-01-01 - 2024-01-15` using `startTime` and `endTime`, you will either receive the charges divided by day, or summed across the first 14 days of the month.

- `groupBy`

    - An array of consumption tags which should be used to group the resulting consumptions. This does _not_ affect the way consumptions are summed, only how they are placed into groups. This can be used to conveniently group consumptions by gvc, org, workload (`name`), etc.

- `consumptionQueries`

    - An array of queries. Most of the time you should have a separate query for each chargeable item.

        - `filterBy` (plain object) This determines which consumptions are included.

            - The keys of this object are tag names. The values are either literal tag values, or regular expressions. To use a regular expression, enclose the value in `/` characters. e.g. `/^gvc-[0-9]+$/`

        - `aggregateBy`

            - An array of tag names to use while summing the queried consumptions. In order to see the charges for a consumption, you must include at least the tag names for a chargable item.


### Example: Querying for CPU Charges

if you want to see CPU charges, you must `aggregateBy` the tags found in the corresponding chargable item. The CPU chargeable item for non-BYOK locations is (at the time of writing):

``` json
{
  "id": "b9892b7c-b3a0-413d-b345-137985fefa35",
  "name": "cpu",
  "description": "The workload CPU metric from Control Plane's metering service",
  "consumptionTags": {
    "feature": "workloads",
    "locationType": "control_plane_hosted",
    "metric": "cpu"
  },
  "unit": "cores * seconds"
}

 ```

So our query would look something like this:

``` json
{
    "detailed": false,
    "startTime": "2024-09-01T00:00:00.000Z",
    "endTime": "2024-10-01T00:00:00.000Z",
    "aggregateByTimeStep": true,
    "timeStep": "month",
    "groupBy": [
        "gvc"
    ],
    "consumptionQueries": [
        {
            "filterBy": {
                "feature": "workloads",
                "locationType": "control_plane_hosted",
                "metric": "cpu"
            },
            "aggregateBy": [
                "feature",
                "locationType",
                "metric",
                "gvc"
            ]
        }
    ]
}

 ```

Note: we aggregate by _at least_ `feature`, `locationType`, and `metric`, because those are the tags listed in the relevant chargeable item. We are of course free to aggregate by any additional tags we like, including `gvc`, `org`, or `workload`.