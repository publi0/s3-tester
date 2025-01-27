is_variable_null() {
  [ -z "$1" ]
}

Describe 'Access the Private with ACL bucket and check the access of objects:' category:"Bucket Permission"
  setup(){
    bucket_name="test-029-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup'
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"029"
    profile=$1
    client=$2
    id=$(aws s3api --profile $profile-second list-buckets | jq -r '.Owner.ID')
    Skip if "No such a "$profile-second" user" is_variable_null "$id"
    aws --profile $profile s3 mb s3://$bucket_name-$client > /dev/null
    aws --profile $profile s3 cp $file1_name s3://$bucket_name-$client > /dev/null
    aws s3api --profile $profile put-bucket-acl --bucket $bucket_name-$client --grant-read id=$id > /dev/null
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    When run aws --profile $profile-second s3api get-object --bucket $bucket_name-$client --key $file1_name $file1_name-2
    The stderr should include "An error occurred (AccessDenied) when calling the GetObject operation: Access Denied."
      ;;
    "rclone")
    When run rclone copy $profile-second:$bucket_name-$client/$file1_name $file1_name-2
    The stderr should include "ERROR"
      ;;
    "mgc")
      mgc profile set-current $profile-second > /dev/null
      #Skip "Skipped test to $client"
      When run mgc object-storage objects download --src $bucket_name-$client/$file1_name --dst $file1_name-2
      The stderr should include "403"
      ;;
    esac
    The status should be failure
    aws s3 rb s3://$bucket_name-$client --profile $profile --force > /dev/null
  End
End
