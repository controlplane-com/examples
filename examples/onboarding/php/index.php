<?php  

echo 'Hello World';  
file_put_contents('php://stdout', 'Workload Name: ' .$_ENV['CPLN_WORKLOAD'] . PHP_EOL); 
file_put_contents('php://stdout', 'Location: ' .$_ENV['CPLN_LOCATION']); 

?> 