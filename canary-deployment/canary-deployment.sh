
#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

Provision() {
    echo "------------------------------------------------------------"
    echo "Canary deployment of reviews-v5 in east cluster"
    echo "Note: This demonstrates shifting only 10% of the traffic to reviews-v5"
    echo "while the rest gets load balanced to reviews-v1 on both clusters"
    echo "------------------------------------------------------------"
    echo ""

    kubectl --context ${MGMT_CONTEXT} apply -f $DIR/ops-team/namespace.yaml
    kubectl --context ${MGMT_CONTEXT} apply -f $DIR/web-frontend-team/namespace.yaml
    kubectl --context ${MGMT_CONTEXT} apply -f $DIR/backend-apis-team/namespace.yaml

    # ---- Ops team ----
    envsubst < <(cat $DIR/ops-team/ops-team-workspace.yaml) | kubectl --context ${MGMT_CONTEXT} apply -f -
    envsubst < <(cat $DIR/ops-team/web-frontend-team-workspace.yaml) | kubectl --context ${MGMT_CONTEXT} apply -f -
    envsubst < <(cat $DIR/ops-team/backend-apis-team-workspace.yaml) | kubectl --context ${MGMT_CONTEXT} apply -f -
    kubectl --context ${MGMT_CONTEXT} apply -f $DIR/ops-team/ops-team-workspace-settings.yaml
    # Inject GW
    envsubst < <(cat $DIR/../one-way-tls-cert-management/north-south-gateway-tls-cert.yaml) | kubectl --context ${WEST_CONTEXT} apply -f -
    envsubst < <(cat $DIR/ops-team/north-south-gateway.yaml) | kubectl --context ${MGMT_CONTEXT} apply -f -
    envsubst < <(cat $DIR/ops-team/primary-route-table.yaml) | kubectl --context ${MGMT_CONTEXT} apply -f -

    # ---- Frontend team ----
    kubectl --context ${MGMT_CONTEXT} apply -f $DIR/web-frontend-team/workspace-settings.yaml
    # Inject RT
    envsubst < <(cat $DIR/web-frontend-team/product-route-table.yaml) | kubectl --context ${MGMT_CONTEXT} apply -f -

    # ---- Backend team ----
    kubectl --context ${MGMT_CONTEXT} apply -f $DIR/backend-apis-team/workspace-settings.yaml
    kubectl --context ${MGMT_CONTEXT} apply -f $DIR/backend-apis-team/reviews-route-table.yaml
    envsubst < <(cat $DIR/backend-apis-team/reviews-virtual-destination.yaml) | kubectl --context ${MGMT_CONTEXT} apply -f -
}

Delete() {
    echo "Cleaning up ..."

    # ---- Ops team ----
    envsubst < <(cat $DIR/ops-team/ops-team-workspace.yaml) | kubectl --context ${MGMT_CONTEXT} delete -f -
    envsubst < <(cat $DIR/ops-team/web-frontend-team-workspace.yaml) | kubectl --context ${MGMT_CONTEXT} delete -f -
    envsubst < <(cat $DIR/ops-team/backend-apis-team-workspace.yaml) | kubectl --context ${MGMT_CONTEXT} delete -f -
    kubectl --context ${MGMT_CONTEXT} delete -f $DIR/ops-team/ops-team-workspace-settings.yaml
    # Inject GW
    #envsubst < <(cat $DIR/ops-team/north-south-gateway-tls-cert.yaml) | kubectl --context ${WEST_CONTEXT} delete -f -
    envsubst < <(cat $DIR/ops-team/north-south-gateway.yaml) | kubectl --context ${MGMT_CONTEXT} delete -f -
    envsubst < <(cat $DIR/ops-team/primary-route-table.yaml) | kubectl --context ${MGMT_CONTEXT} delete -f -

    # ---- Frontend team ----
    kubectl --context ${MGMT_CONTEXT} delete -f $DIR/web-frontend-team/workspace-settings.yaml
    # Inject RT
    envsubst < <(cat $DIR/web-frontend-team/product-route-table.yaml) | kubectl --context ${MGMT_CONTEXT} delete -f -

    # ---- Backend team ----
    kubectl --context ${MGMT_CONTEXT} delete -f $DIR/backend-apis-team/workspace-settings.yaml
    kubectl --context ${MGMT_CONTEXT} delete -f $DIR/backend-apis-team/reviews-route-table.yaml
    envsubst < <(cat $DIR/backend-apis-team/reviews-virtual-destination.yaml) | kubectl --context ${MGMT_CONTEXT} delete -f -
}

shift $((OPTIND-1))
subcommand=$1; shift
case "$subcommand" in
    prov )
        Provision
    ;;
    del )
        Delete
    ;;
    * ) # Invalid subcommand
        if [ ! -z $subcommand ]; then
            echo "Invalid subcommand: $subcommand"
        fi
        exit 1
    ;;
esac