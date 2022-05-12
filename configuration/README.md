# USER CREATING 

1. Certificate signing

Generate private rsa key file:

    openssl genrsa -out user1.key 2048

Create request:

    openssl req -new -key user1.key -subj "/CN=user1" -out user1.csr 

Make base64 request:

    cat user1.csr | base64 | tr -d "\n"

Past pequest key to user1-csr.yaml

Apply request file:

    kubectl apply -f user1-csr.yaml

Approve csr:

    kubectl certificate approve user1

Get certificate:

    kubectl get csr user1 -o yaml

Decode certificate and save in file:

    ecco 'actual certificate from file user1 -o yaml' | base64 --decode > user1.crt

Connect to cluster using generated files:

    kubectl --server=http://192.168.1.111:6443 \
    --certificate-authority=/etc/kubernetes/pki/ca.crt \
    --client-certificate=user1.crt \
    --client-key=user1.key \