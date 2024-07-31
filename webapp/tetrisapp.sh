	GROUP_NAME="RG_JPP_ARC_Phoenix" # Name of the Resource Group
	CLUSTER_NAME="ubuntuarc2" # Cluster Name
	EXTENSION_NAME="ubuntuarc2-arc-environment" # Name of the App Service extension
	NAMESPACE="tetris-webapp" # Namespace in your cluster to install the extension and provision resources
	KUBE_ENVIRONMENT_NAME="tetris-appservice" # Name of the App Service K8S environment resource
    ASP_NAME="ASP-TetrisARC"
    APP_NAME="TetrisARC"
    CUSTOM_LOCATION_NAME="Phoenix"
	
	## Este paso es solo para un cluster que no tenga la extensión añadida. Para la demo no hace falta.
	## El siguiente comando añade la extensión al cluster
	# az k8s-extension create \
	#        --resource-group $GROUP_NAME \
	#        --name $EXTENSION_NAME \
	#        --cluster-type connectedClusters \
	#        --cluster-name $CLUSTER_NAME \
	#        --extension-type 'Microsoft.Web.Appservice' \
	#         --release-train stable \
	#        --auto-upgrade-minor-version true \
	#        --scope cluster \
	#        --release-namespace $NAMESPACE \
	#        --configuration-settings "Microsoft.CustomLocation.ServiceAccount=default" \
	#        --configuration-settings "appsNamespace=${NAMESPACE}" \
	#         --configuration-settings "clusterName=${KUBE_ENVIRONMENT_NAME}" \
	#        --configuration-settings "keda.enabled=false" \
	#        --configuration-settings "buildService.storageClassName=microk8s-hostpath" \
	#        --configuration-settings "buildService.storageAccessMode=ReadWriteOnce" \
	#        --configuration-settings "customConfigMap=${NAMESPACE}/kube-environment-config"
	
	
	## Los siguientes comandos añaden la "custom Location"
	
	#CUSTOM_LOCATION_NAME="Phoenix"
	
    CONNECTED_CLUSTER_ID=$(az connectedk8s show --resource-group $GROUP_NAME --name $CLUSTER_NAME --query id --output tsv)
	
	EXTENSION_ID=$(az k8s-extension show --cluster-type connectedClusters --cluster-name $CLUSTER_NAME --resource-group $GROUP_NAME --name $EXTENSION_NAME --query id --output tsv)
	
	## Este paso es solo en caso de que no existe una Custom Location. Para la demo no hace falta.
	# az customlocation create \
	#        --resource-group $GROUP_NAME \
	#        --name $CUSTOM_LOCATION_NAME \
	#        --host-resource-id $CONNECTED_CLUSTER_ID \
	#        --namespace $NAMESPACE \
	#        --cluster-extension-ids $EXTENSION_ID  
	
	CUSTOM_LOCATION_ID=$(az customlocation show --resource-group $GROUP_NAME --name $CUSTOM_LOCATION_NAME --query id --output tsv)
	
	##Creamos la web app
	az appservice kube create \
	        --resource-group $GROUP_NAME \
	        --name $KUBE_ENVIRONMENT_NAME \
	        --custom-location $CUSTOM_LOCATION_ID
	
	##Creamos el service plan (hay un bug en az y no lo permite crear, pero lo crea la app con plan K1 que es gratuito mientras esta en preview)
    ##NOTA: En preview no permite la creación de App Service Plan. Al desplegar la web se crea automatico
	#ASP_NAME=ASP-ubuntuarc2-kube
	#az appservice plan create \
	#        --resource-group $GROUP_NAME \
	#        --name $ASP_NAME \
	#        --app-service-environment $KUBE_ENVIRONMENT_NAME \
	#        --is-linux \
	#        --custom-location $CUSTOM_LOCATION_ID \
    #        --sku K1
	
	##Subimos una app contenereizada, se puede subir una app con código también
	#APP_NAME=ubuntuarc2-app-demo 
	az webapp create \
	        --resource-group $GROUP_NAME \
	        --name $APP_NAME \
	        --custom-location $CUSTOM_LOCATION_ID \
	        --deployment-container-image-name docker.io/jorgeperona/arctetris
	
	###--plan $ASP_NAME (se quita por un bug en az, se deja que el lo autocree)
	
	
