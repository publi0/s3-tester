Describe 'Create private bucket:' category:"Bucket Permission"
  setup(){
    bucket_name="test-021-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup' 
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"021"
    profile=$1
    client=$2
    case "$client" in
    "aws-s3api" | "aws")
      When run aws --profile $profile s3api create-bucket --bucket $bucket_name-$client
      The output should include "\"Location\": \"/$bucket_name-$client\""
      ;;
    "aws-s3")
      When run aws --profile $profile s3 mb s3://$bucket_name-$client
      The output should include "make_bucket: $bucket_name-$client"
      ;;
    "rclone")
      When run rclone mkdir $profile:$bucket_name-$client -v
      The error should include "Bucket \"$bucket_name-$client\" created"
      ;;
    "mgc")
      mgc profile set-current $profile > /dev/null
      When run mgc object-storage buckets create $bucket_name-$client
      The output should include "Created bucket $bucket_name-$client"
      ;;
    esac
    The status should be success
    aws s3 rb s3://$bucket_name-$client --profile $profile --force > /dev/null
  End
End
