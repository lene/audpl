function ssh_aws
	ssh  -i  ~/.ssh/ireland.pem  ubuntu@{$argv[1]}.eu-west-1.compute.amazonaws.com
end
