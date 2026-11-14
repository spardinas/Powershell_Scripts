
# Readme

## Retrieve membership from Security Groups in Entra


This script was meant to be used for non-admin users, so the execution is made via App Registration. following updates will change to other forms of auth.
So first you have to create an App Registration with ReadOnly permissions, and a Secret. Update the script with the info.

It accept a parameter: -Transitive
With it, it also list nested groups.

