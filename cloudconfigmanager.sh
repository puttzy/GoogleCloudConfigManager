#!/usr/bin/env bash


# SELECTED_CONFIG_NAME="TEST"


main_menu() {

    echo
    echo
    echo Main Options
    echo [1] Init/Switch Config
    echo [2] List variables
    echo [3] Update variable
    echo [4] Delete variable
    echo [5] Add variable
    echo [6] Create New Config
    echo [7] Delete Config

    echo [8] Exit
    read -p "Please select an option: " SELECTED_CONFIG

    if [[ $SELECTED_CONFIG -eq 1 ]]
    then
        gcloud init
    elif [[ $SELECTED_CONFIG -eq 2 ]]
    then
        config_list 1
        variable_list 0 "variables set in '${SELECTED_CONFIG_NAME}'"
    elif [[ $SELECTED_CONFIG -eq 3 ]]
    then
        config_list 1
        variable_list 1 "Config Name: '${SELECTED_CONFIG_NAME}' \n " "Select a variable (index) to update: "
        update_variable
    elif [[ $SELECTED_CONFIG -eq 4 ]]
    then
        config_list 1
        variable_list 1 "Config Name: '${SELECTED_CONFIG_NAME}' \n " "Select a variable (index) to delete: "
        delete_variable
    elif [[ $SELECTED_CONFIG -eq 5 ]]
    then
        config_list 1
        add_variable
    elif [[ $SELECTED_CONFIG -eq 6 ]]
    then
        create_config
    elif [[ $SELECTED_CONFIG -eq 7 ]]
    then
        delete_config
    elif [[ $SELECTED_CONFIG -eq 8 ]]
    then
        exit
    fi

    main_menu
}


delete_config(){
    read -p "What is the name of the configuration you'd like to delete: " NEW_CONFIG_NAME
    gcloud beta runtime-config configs delete ${NEW_CONFIG_NAME}
    config_list 1 0
}

create_config(){
    read -p "What is the name of the configuration you'd like to create: " NEW_CONFIG_NAME
    gcloud beta runtime-config configs create ${NEW_CONFIG_NAME}
    config_list 1 0
}

list_variables() {
    config_list 1
    variable_list
}



is_number() {
    if ! [[ "$1" =~ ^[0-9]+$ ]]
    then
        echo Invalid Option.  Expected a number
    fi

}

update_variable(){
    echo
    read -p "Enter new value for ${SELECTED_VARIABLE_NAME} in ${SELECTED_CONFIG_NAME}: " NEW_VALUE
    gcloud beta runtime-config configs variables set ${SELECTED_VARIABLE_NAME} ${NEW_VALUE} --config-name=${SELECTED_CONFIG_NAME}
}

delete_variable(){
    echo
    read -n1 -p "Are you sure you want to delete ${SELECTED_VARIABLE_NAME} in the ${SELECTED_CONFIG_NAME} [y/n]: "  CONFIRM

    if [[ ${CONFIRM} -eq "Y" ]]
    then
        gcloud beta runtime-config configs variables unset ${SELECTED_VARIABLE_NAME}  --config-name=${SELECTED_CONFIG_NAME}
    else
        echo
        echo "Not deleting anything"
        echo
    fi
}

add_variable(){
    echo
    read -p "Variable Name: "  VARIABLE_NAME
    read -p "Variable Value: "  VARIABLE_VALUE
    gcloud beta runtime-config configs variables set ${VARIABLE_NAME} ${VARIABLE_VALUE} --config-name=${SELECTED_CONFIG_NAME}

}




variable_list() {
    SHOW_INDEX=$1
    HEADER=$2
    PROMPT=$3

    echo -e ${HEADER}
    VARIABLE_COUNTER=0
    VARIABLE_LIST=()

    VARIABLES=$( gcloud beta runtime-config configs variables list  --config-name=${SELECTED_CONFIG_NAME} --format 'value(NAME)')
    for VARIABLE in ${VARIABLES}
    do
        ((VARIABLE_COUNTER = VARIABLE_COUNTER+1))

        VARIABLE_LIST+=(${VARIABLE})
        VARIABLE_VALUE=$(gcloud beta runtime-config configs variables get-value ${VARIABLE} --config-name ${SELECTED_CONFIG_NAME})
        if [[ SHOW_INDEX -eq 1 ]]
        then
            echo "[$VARIABLE_COUNTER] $VARIABLE = '$VARIABLE_VALUE'"
       else
            echo "$VARIABLE = '$VARIABLE_VALUE'"
        fi

    done

    if [[ ! -z "$PROMPT" ]]
    then
        read -p "${PROMPT}" SELECT_VARIABLE_INDEX
        if ! [[ "$SELECTED_CONFIG_INDEX" =~ ^[0-9]+$ ]]
        then
            echo -e \n\n     Invalid option!! please select a number between 1 and ${VARIABLE_COUNTER}
            variable_list ${SHOW_INDEX} "${HEADER}" "${PROMPT}"
        fi

        if [[ ${SELECT_VARIABLE_INDEX} -gt ${VARIABLE_COUNTER} ]] || [[ ${SELECT_VARIABLE_INDEX} -lt 1 ]]
        then
            echo
            echo -e \n\n      Invalid option!! please select a number between 1 and ${VARIABLE_COUNTER}
            variable_list ${SHOW_INDEX} "${HEADER}" "${PROMPT}"
        fi
    fi

    SELECTED_VARIABLE_NAME=${VARIABLE_LIST[$SELECT_VARIABLE_INDEX-1]}
}


config_list() {
    SHOW_LIST=$1
    SHOW_PROMPT=$2

    if [[ ! -z "$SHOW_PROMPTT" ]]
    then
        echo setting default show prompt
        SHOW_PROMPT=1
    fi

    if [[ SHOW_LIST -eq 1 ]]
    then
        echo
        echo
        echo Available Cloud Configs:
        CONFIG_COUNTER=0
        CONFIG_LIST=()
        CONFIGS=$( gcloud beta runtime-config configs list --format 'value(NAME)')

        for CONFIG in ${CONFIGS}
        do
            ((CONFIG_COUNTER = CONFIG_COUNTER+1))
            echo "[$CONFIG_COUNTER] $CONFIG"
            CONFIG_LIST+=(${CONFIG})
        done
        echo
    fi

    if [[ SHOW_PROMPT -eq 1 ]]
        then
        echo
        read -p "Which cloud config would you like to use: " SELECTED_CONFIG_INDEX
        echo

        if ! [[ "$SELECTED_CONFIG_INDEX" =~ ^[0-9]+$ ]]
        then
            echo Invalid option!! please select a number between 1 and ${CONFIG_COUNTER}
            config_list 0
        fi

        if [[ ${SELECTED_CONFIG_INDEX} -gt ${CONFIG_COUNTER} ]] || [[ ${SELECTED_CONFIG_INDEX} -lt 1 ]]
        then
            echo
            echo Invalid option!! please select a number between 1 and ${CONFIG_COUNTER}
            config_list 0
        fi
    fi
    # echo You Selected ${SELECTED_CONFIG_INDEX} ${CONFIG_LIST[$SELECTED_CONFIG_INDEX-1]}
    SELECTED_CONFIG_NAME=${CONFIG_LIST[$SELECTED_CONFIG_INDEX-1]}
}

project_display(){
    echo
    echo
    CURRENT_PROJECT=$(  gcloud config list --format 'value(core.project)')
    echo Current Project: ${CURRENT_PROJECT}
    echo -e "\n\n If you'd like to select a different project please [1] Init/Switch Config"
}



project_display
main_menu
# config_list 1
# variable_list
