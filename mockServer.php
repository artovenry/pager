<?
header("Access-Control-Allow-Origin: *");

try{
  if($_GET["fail"] === "timeout"){
    sleep(6);
  }elseif($_GET["fail"] === "error"){
    throw new Exception;
  }
  http_response_code(200);
}catch(Exception $e){
  http_response_code(500);
}

$data=[
  "hoge"=> false
];
header('Content-Type: application/json');
echo json_encode($data);