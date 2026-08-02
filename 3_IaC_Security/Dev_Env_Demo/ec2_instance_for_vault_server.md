# Creating an EC2 Instance with Your Key Pair – Step by Step (.txt)

```text
====================================================================
                 UNDERSTANDING EC2 INSTANCE CREATION
====================================================================

An EC2 instance is simply a virtual computer (Virtual Machine)
running inside AWS (or your AWS-compatible environment).

Think of it like this:

                    Your Laptop
                         |
                         | Requests a VM
                         v
                +-------------------+
                |   AWS / Local AWS |
                +-------------------+
                         |
                         v
                +-------------------+
                |  EC2 Instance     |
                | (Ubuntu Linux VM) |
                +-------------------+

====================================================================
STEP 1 : WHAT IS AN AMI?
====================================================================

AMI = Amazon Machine Image

An AMI is a template used to create an EC2 instance.

Think of it like an operating system installation DVD.

Examples:

Ubuntu 22.04
Amazon Linux
Red Hat Enterprise Linux
Windows Server

Without an AMI, AWS doesn't know which operating system to install.

Visualization

              +----------------------+
              | Ubuntu AMI           |
              |----------------------|
              | Ubuntu OS Files      |
              | Boot Configuration   |
              | Default Packages     |
              +----------+-----------+
                         |
                         v
                Creates EC2 Instance

====================================================================
STEP 2 : WHAT IS INSTANCE TYPE?
====================================================================

Instance Type defines the hardware configuration of your VM.

It specifies:

• CPU (vCPUs)
• Memory (RAM)
• Network Performance
• Storage Capabilities

Example:

t3.micro

Breakdown:

t3
---
The instance family.

The "t" family provides burstable CPU performance.
It is designed for workloads that are idle most of the time but
occasionally require more CPU power.

Examples:
Web servers
Development machines
Testing environments
Small applications

micro
-----
The size of the instance.

AWS provides multiple sizes.

+-----------+------------------------+
| nano      | Very Small             |
| micro     | Small                  |
| small     | Slightly Bigger        |
| medium    | Medium                 |
| large     | Large                  |
| xlarge    | Extra Large            |
+-----------+------------------------+

So,

t3.micro means

Family : t3
Size   : micro

Visualization

          Instance Type
                |
      +---------+---------+
      |                   |
      v                   v
 Family (t3)          Size (micro)

====================================================================
STEP 3 : WHY DO WE NEED A KEY PAIR?
====================================================================

A key pair allows secure login into your EC2 instance.

When you created

aws ec2 create-key-pair --key-name prajwal

AWS created

Public Key
Private Key (prajwal.pem)

The public key is stored with AWS.

The private key remains only with you.

Authentication Flow

              AWS
               |
        Stores Public Key
               |
               |
Your Laptop -------------------------
      |                             |
      | Uses prajwal.pem            |
      v                             |
      SSH Authentication            |
               |                    |
               +--------------------+
                     Keys Match?
                           |
                  Yes --------------> Login Allowed
                  No ---------------> Login Denied

====================================================================
STEP 4 : CREATING THE EC2 INSTANCE
====================================================================

Example Command

aws ec2 run-instances \
    --image-id ami-ubuntu2204 \
    --instance-type t3.micro \
    --key-name prajwal \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=vault-server}]'


Let's understand every parameter.

--------------------------------------------------------------------

--image-id ami-xxxxxxxx

Specifies which operating system to install.

Example

Ubuntu AMI

Without this,
AWS doesn't know what OS to launch.

--------------------------------------------------------------------

--instance-type t3.micro

Specifies the virtual hardware.

It tells AWS

"I want a small virtual machine."

AWS allocates

CPU
RAM
Networking

based on this instance type.

--------------------------------------------------------------------

--key-name prajwal

This is NOT your .pem file.

It is the name of the key pair stored in AWS.

AWS finds the public key named

prajwal

and injects it into the Ubuntu VM during launch.

Your private key

prajwal.pem

stays on your computer.

====================================================================
STEP 5 : WHAT HAPPENS INTERNALLY?
====================================================================

You execute

aws ec2 run-instances
        |
        |
        v
AWS receives request
        |
        |
        v
Find Ubuntu AMI
        |
        |
        v
Allocate CPU
Allocate RAM
Allocate Storage
        |
        |
        v
Create Virtual Machine
        |
        |
        v
Install Ubuntu
        |
        |
        v
Copy Public Key
(prajwal)
        |
        |
        v
Boot Ubuntu
        |
        |
        v
Return Instance ID

====================================================================
STEP 6 : WHERE IS prajwal.pem USED?
====================================================================

Notice that

run-instances

does NOT use the .pem file.

It only uses

--key-name prajwal

The .pem file is needed later when you connect.

Example

ssh -i prajwal.pem ubuntu@<Public-IP>

Flow

Create Key Pair
       |
       v
Save prajwal.pem
       |
       v
Launch EC2
(--key-name prajwal)
       |
       v
AWS installs Public Key
       |
       v
Use prajwal.pem
to authenticate via SSH

====================================================================
SUMMARY
====================================================================

AMI
----
Operating system template.

Example:
Ubuntu 22.04

Instance Type
-------------
Defines the VM hardware.

Example:
t3.micro

Key Pair
--------
Authentication mechanism.

Public Key
Stored by AWS.

Private Key (.pem)
Stored securely by you.

--key-name
----------
Refers to the public key stored by AWS.

prajwal.pem
-----------
Used only when connecting to the instance using SSH.

Workflow

+--------------------------------------------------------------+
| Step 1 : Create Key Pair (Completed ✓)                       |
+--------------------------------------------------------------+
                         |
                         v
+--------------------------------------------------------------+
| Step 2 : Save Private Key as prajwal.pem                     |
+--------------------------------------------------------------+
                         |
                         v
+--------------------------------------------------------------+
| Step 3 : Launch Ubuntu EC2 Instance                          |
|          using --key-name prajwal                            |
+--------------------------------------------------------------+
                         |
                         v
+--------------------------------------------------------------+
| Step 4 : AWS Copies the Public Key into Ubuntu               |
+--------------------------------------------------------------+
                         |
                         v
+--------------------------------------------------------------+
| Step 5 : SSH Using prajwal.pem                               |
+--------------------------------------------------------------+

Congratulations! At this point, you'll have an Ubuntu EC2 instance
that trusts the public key named "prajwal", and you'll authenticate
to it using your local "prajwal.pem" private key.
```
