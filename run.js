var filename = "pandas/src/resources/json_data/raw-iana-service-names-port-numbers.json";
function put_records(file) {
  var axios = require("axios");
  var fs = require("fs");
  fs.readFile(file, "utf8", function (err, data) {
    if (err) {
      return console.log(err);
    }
    res = JSON.parse(data);
    console.log(res)
    // Array.from(res).map((data) => {
      var url = "https://1hxc39w0uc.execute-api.us-east-1.amazonaws.com/serverless_lambda_stage"
      var config = {
        method: "put",
        url: url,
        headers: {
          "Content-Type": "application/json",
        },
        data: JSON.stringify(data),
      };

      axios(config)
        .then(function (response) {
          console.log(JSON.stringify(response.data));
        })
        .catch(function (error) {
          console.log(error);
        });
    // }); //Array

  }); // readfile
}

put_records(filename)


