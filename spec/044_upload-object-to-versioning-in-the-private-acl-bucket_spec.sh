Describe 'Upload object to versioning in the private acl bucket:' category:"Object Versioning"
  setup(){
    bucket_name="test-044-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup'
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"044"
    profile=$1
    client=$2    
    id="fake-user"
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    aws --profile $profile s3 mb s3://$bucket_name-$client
    aws s3api --profile $profile put-bucket-acl --bucket $bucket_name-$client --grant-write id=$id --grant-read id=$id
    aws s3api --profile $profile put-bucket-versioning --bucket $bucket_name-$client --versioning-configuration Status=Enabled
    When run aws --profile $profile-second s3 cp $file1_name s3://$bucket_name-$client
    The status should be success
    The output should include "$file1_name"
    aws --profile $profile s3api delete-objects --bucket $bucket_name-$client --delete "$(aws --profile $profile s3api list-object-versions --bucket $bucket_name-$client| jq '{Objects: [.Versions[] | {Key:.Key, VersionId : .VersionId}], Quiet: false}')" | jq
    aws --profile $profile s3 rb s3://$bucket_name-$client --force
      ;;
    "rclone")
    aws --profile $profile s3 mb s3://$bucket_name-$client
    aws s3api --profile $profile put-bucket-acl --bucket $bucket_name-$client --grant-write id=$id --grant-read id=$id
    aws s3api --profile $profile put-bucket-versioning --bucket $bucket_name-$client --versioning-configuration Status=Enabled
    When run rclone copy $file1_name $profile-second:$bucket_name-$client
    The status should be success
    The output should include ""
    aws --profile $profile s3api delete-objects --bucket $bucket_name-$client --delete "$(aws --profile $profile s3api list-object-versions --bucket $bucket_name-$client| jq '{Objects: [.Versions[] | {Key:.Key, VersionId : .VersionId}], Quiet: false}')" | jq
    aws --profile $profile s3 rb s3://$bucket_name-$client --force
      ;;
    "mgc")
    Skip 'Teste pulado para cliente mgc'
    # aws --profile $profile s3api create-bucket --bucket $bucket_name-$client --acl public-read | jq
    # aws s3api --profile $profile put-bucket-versioning --bucket $bucket_name-$client --versioning-configuration Status=Enabled
    # mgc object-storage buckets acl set --grant-read id=$id --bucket $bucket_name-$client
    # When run mgc object-storage objects upload --src $file1_name --dst $bucket_name-$client
    # The status should be success
    # The output should include ""
    # aws --profile $profile s3api delete-objects --bucket $bucket_name-$client --delete "$(aws --profile $profile s3api list-object-versions --bucket $bucket_name-$client| jq '{Objects: [.Versions[] | {Key:.Key, VersionId : .VersionId}], Quiet: false}')" | jq
    # aws --profile $profile s3 rb s3://$bucket_name-$client --force
      ;;
    esac
  End
End