<?
header("Access-Control-Allow-Origin: *");

try{
  if($_GET["fail"] === "timeout"){
    usleep(6000 * 1000);
  }elseif(isset($_GET["fail"])){
    throw new Exception($_GET["fail"]);
  }
  usleep(1300 * 1000);
  http_response_code(200);
}catch(Exception $e){
  http_response_code($e->getMessage());
}

$LENGTH= 17;
$offset= $_GET["offset"];
$limit= $_GET["limit"];
$articles= [];
foreach(array_slice(range(0, $LENGTH - 1), $offset, $limit) as $i){
  $template= function($page= null){
    ob_start();
    include "./lipsum.html.php";
    $rs= ob_get_contents();ob_end_clean();
    return ["html"=>$rs];
  };
  $articles[]= $template($i);
}

$data=[
  "finished" => $i == $LENGTH - 1,
  "articles" =>$articles
];
header('Content-Type: application/json');
echo json_encode($data);
