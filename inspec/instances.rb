control "Should only have instances associated with my app" do
  aws_ec2_instances.instance_ids.each do |instance_id|
    describe aws_ec2_instance(instance_id) do
      its('instance_type') { should cmp 't2.micro' }
      its('tags') { should include(key:'X-Application', value:'Testing Terraform') }
    end
  end
end

