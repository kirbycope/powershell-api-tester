# Get the current directory
$pwd = pwd

# Import the required assemblies (dynamic link library)
Add-Type -Path "$pwd\Newtonsoft.Json.dll"
Add-Type -Path "$pwd\System.Net.Http.dll"

# Globals
$baseUrl = "https://jsonplaceholder.typicode.com/"
$client = New-Object -TypeName System.Net.Http.Httpclient
$pathToCsv = "$pwd\testplan.csv"

# Do something with each line in the csv file
$csv = Import-csv -path $pathToCsv
foreach($line in $csv)
{
    # Create an empty array to hold any errors
    $errors = @()
    
    # Create a description for the log
    $description = "[" + $line.Id + "] (" + $line.Authentication + ") Attempt a " + $line.Method + " of the '"+ $line.Endpoint + "' endpoint"
    
    # Create the request
    $request = New-Object -TypeName System.Net.Http.HttpRequestMessage
    $request.Method = $line.Method
    $request.RequestUri = $baseUrl + $line.Endpoint
    if ( ($line.Method -eq "POST") -or ($line.Method -eq "PUT") ) {
            $request.Content = New-Object -TypeName System.Net.Http.StringContent $line.Body
            $request.Content.Headers.ContentType = "application/x-www-form-urlencoded"
    }

    # Get the response of the request
    $response = $client.SendAsync($request).Result

    # Get the status code
    $statusCode = $response.StatusCode

    # Get the response content as a string
    $responseContent = $response.Content.ReadAsStringAsync().Result
    
    # ~Assertions~ Add messages to the error array using "$errors += $_value"
    
    # Ensure that the status code matches the expected value
    if ($statusCode -ne $line.ExpectedStatus) {
        $errors += "    Status code " + $line.ExpectedStatus + " was expected, but got " + $statusCode
    }

    # Print the test result
    if ($errors.Length -eq 0) {
        Write-Host $description -ForegroundColor Green
    } else {
        Write-Host $description -ForegroundColor Red
        foreach ($err in $errors) {
            Write-Host $err
        }
    }

    # If there is a comment, write that to the log too
    if ($line.Comment.Length -gt 0) {
        Write-Host "    Comment: " $line.Comment -ForegroundColor Gray
    }
}