control 'Make sure unrestricted SSH is not permitted' do
  # Loop over each of the security group IDs in the region
  aws_security_groups.group_ids.each do |group_id|
    # Examine a security group in detail
    describe aws_security_group(group_id) do
      # Examine Ingress rules, and complain if 
      # there is unrestricted SSH
      it { should_not allow_in(port: 22, ipv4_range: '0.0.0.0/0') }
    end
  end
end

control 'The only world-open security groups should be on the ELB' do
  elb_sg_ids = aws_elbs.security_group_ids
  aws_security_groups.group_ids.each do |sg_id|
    sg = aws_security_group(sg_id)
    if sg.allow_in? ipv4_range: '0.0.0.0/0'
      describe sg do
        its('group_id') { should be_in elb_sg_ids }
        it { should allow_in_only port: 80 }
      end
    end 
  end
end

