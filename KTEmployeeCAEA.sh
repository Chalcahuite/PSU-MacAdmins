#!/bin/bash
value=$(profiles -P | awk '/1A2B3C4D-EFGH-5678-90I1-2345678901JK/ {print $4}') #Use profile ID. 
	if [[ -n "$value" ]]; then
		echo "<result>True</result>"
		else
		echo "<result>False</result>"
	fi
	
