Instalação sistema operacional [ CentOS ] 

Configurações da máquina virtual
1 processador
2 núcleos
4GB de RAM no mínimo 
Disco 40GB
Habilitar a opção VTX e AMD no processador  

Para entender o que é OVS tem um link nestá sessão é muito importante que você leia.


Fazer copia da interface original, vamos chamar fisica.

[Comando]
#cp /etc/sysconfig/network-scripts/ifcfg-ens33 /et/sysconfig/network-scripts/ifcfg-br-ex =  este é um caminho absoluto
você já está dentro do da pasta onde fica os arquivos de configuração de interface [cp ifcfg-ens33 ifcfg-br-ex]


[Interface ens33] tem que está com estas configurações
-------------------------------------------------------
DEVICE=ens33

ONBOOT=yes

DEVICETYPE=ovs

TYPE=OVSPort

OVS_BRIDGE=br-ex
------------------------------------------------------

[Interface br-ex] tem que está com estas configurações

DEVICE=ens33

DEVICETYPE=ens33 

TYPE=OVSBridge 

BOOTPROTO=static 

IPADDR=192.168.1.123 

NETMASK=255.255.252.0 

GATEWAY=192.168.1.6 

DNS1=8.8.8.8

DNS2=8.8.4.4 

ONBOOT=yes 
----------------------------------------------------

Temos que reiniciar o servidor de rede
#systemctl restart network
#systemctl restart http

temos que configurar os drivers de rede neutron para que tudo funciona conforme queremos, o arquivo /etc/neutron/plugins/ml2/ml2_conf.ini deverá ser alterado para
suportar os drivers que iremos usar no curso.

[type_drivers = vxlan,gre,vlan,flat,local]


Reiniciar o serviço do Neutron após finalizar:
#openstack-service restart neutron





#yum install -y epel-release bash-completion

Auto completar os comandos digitados
#yum install bash-completion vim -y

Atualizando o sistema
#yum upgrade -y
Verificar quais repositórios em tenho opensack 
#yum search openstack

Instalar o repositório  openstack
Yum install -y [nome do repositório]

Instalando pacote openstack
#yum install -y openstack-packstack

