param (
   [Parameter(Mandatory=$true)][string]$company_number,
   [string]$token = "tVm3HyDxi7txG3cmKakb198OumLOcWSMSRTMfBqq",
   [int]$items_per_page = 100,
   [switch]$help = $false
   )

if ($help) {
  echo "Hi there. This SmajTech script takes a companies house company number and downloads the entire filing history of that company from the Companies House api. 
You can pass this script the following flags to do some stuff:
-v    This will make the script verbose.
-i    This lets you choose the max number of files you want to download.
-t    This lets you choose your token to authenticate to the API. By default we use Nujcharee Haswell's token.

usage: filing.sh -v -i 3 -t <TOKEN> <COMPANY NUMBER>"
  exit(1)
  }

Write-Verbose "Being Verbose!"
Write-Verbose "We are using token: $token"

# Check whether jq is installed:
$jq_version = $(./jq --version)
if (!$?) {
  echo "You will need to ensure that jq is installed and added to your PATH."
  exit(2)
}else {
  Write-Verbose "Running with jq version: $jq_version"  
}

Write-Verbose "Downloading list of documents associated with company: $company_number"

# make poewrshell connect tls 1.2
[Net.ServicePointManager]::SecurityProtocol = 
        [Net.SecurityProtocolType]::Tls12

$token_auth = "${token}:"

$bytes = [System.Text.Encoding]::ASCII.GetBytes($token_auth)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{ Authorization = $basicAuthValue }

$doc_list = (Invoke-WebRequest -uri https://api.companieshouse.gov.uk/company/$company_number/filing-history?items_per_page=$items_per_page -Headers $headers).Content

$num_docs = echo $doc_list | ./jq -r '.total_count'

if ($num_docs -eq 0) {
  echo "ERROR: No documents found for this company_number

exitting..
  "
  exit(3)
}
Write-Verbose "Creating directory '$company_number' for company documents"
New-Item -ItemType directory -Path ./$company_number -Force

Write-Verbose "Downloading $num_docs documents.."

For ($i=0; $i -le $num_docs; $i++) {
    $filename = echo $doc_list | ./jq -r ".items[$i]|.description"
    $doc_string = echo $doc_list | ./jq -r ".items[$i]|.links.document_metadata"
    $id = $doc_string.Substring($doc_string.Length - 43)
    if ( $id.length -ne 0 ) {
        Write-Verbose "Downloading file: $filename"
        Invoke-WebRequest -uri http://document-api.companieshouse.gov.uk/document/$id/content -outfile "$company_number/$i-$filename.pdf" -Headers $headers
    }
  }
echo "Done!"



