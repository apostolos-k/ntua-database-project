// execute SQL code specified in the pg_query parameter
// of a multipart/form-data POST and return the results
// 
// Sample usage:
// echo 'SELECT NOW();' | curl /api/postgresbot -F pg_query='<-' 


const parse = require("pg-connection-string").parse;
const { Client } = require("pg");
const version = "202205";


export default async function handler(req, res) {
  res.setHeader('X-Version', version);

  // pg_query POST (multipart/form-data) parameter?
  var pg_query = "";
  if (req && req.body && req.body.pg_query){
    pg_query = req.body.pg_query;
  }


  // pg_connection_string POST (multipart/form-data) parameter?
  var pg_connection_string = process.env["pg_connection_string"] || "";
  var config = {}, client = {};
  try {
    config = parse(pg_connection_string);
    client = new Client(config);
  } catch (err) {
    fail(`error parsing connection string: ${err}`);
  }


  var pg_response = {};
  try {
    await client.connect();
    pg_response = await client.query(pg_query);
//  console.log(pg_response.rows[0].message)
    await client.end()
  } catch (err) {
//  console.log(`error connecting: ${err}`)
    fail(`error connecting: ${err}`);
  }

  client.end();	     // close connection to DB

//res.setHeader('X-pg_query', JSON.stringify(pg_query));

  // return query results
  res.status(200).json(pg_response)
  return;


  function fail(message){
    res.status(400).json({"error": message})
  }


}

