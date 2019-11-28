#!/bin/bash
#
# versao 0.1
#
# INFORMAÇÕES
#   SpamRule.sh         
#
# DESCRICAO
#   Atualiza regras de anti-spam dos servidores de E-mail
#
# NOTA
#   Testado e desenvolvido no Centos 7 e Centos 6
#   
#  DESENVOLVIDO_POR
#  Jeferson Zacarias Sens       -        jefe.zaca@icloud.com
#
#########################################################################################################################################

# Variaveis
log="/var/log/spamrule.log"
subjectrule="/etc/mail/spamassassin/HardtecSubject.cf"
bodyrule="/etc/mail/spamassassin/HardtecBody.cf"
subjectdownloaded="/tmp/HardtecSubject.cf"
bodydownloaded="/tmp/HardtecBody.cf"
wgetsubject="https://raw.githubusercontent.com/Crusher131/Hardtec.cf/master/HardtecSubject.cf"
wgetbody="https://raw.githubusercontent.com/Crusher131/Hardtec.cf/master/HardtecBody.cf"
paramwget=" --directory-prefix=/tmp/ -q --no-check-certificate"
getfile="/usr/bin/wget"

#Função responsavel pelo Log
Log(){
    if [ -z "$1" ]; then
        cat
    else
        printf '%s\n' "$@" 
    fi | tee -a "$log"
}

MailerRestart(){
    service mailscanner restart
    restart=$?

    if [ $restart != 0 ]; then
            service MailScanner restart
    fi
}

#Função responsavel por limpar os arquivos baixados
RemoveFiles() {
    rm -rfv $bodydownloaded
    echo ""
    rm -rfv $subjectdownloaded
MailerRestart
}

#Função responsavel por checar os arquivos Baixados
CopyFiles2() {
    if [ "$bodyvalue" -eq 1 ]; then
        echo ""
        echo "Subistituindo Arquivo $subjectrule por $subjectdownloaded"
        cp -f $bodydownloaded $bodyrule
    else
        echo ""
        echo "Arquivo $bodyrule é igual ao $bodydownloaded nenhuma ação foi tomada"
    fi
    RemoveFiles
}

#Função responsavel por checar os arquivos Baixados
CopyFiles() {
    if [ "$subjectvalue" -eq 1 ]; then
        echo ""
        echo "Subistituindo Arquivo $subjectrule por $subjectdownloaded"
        cp -f $subjectdownloaded $subjectrule
    else
        echo ""
        echo "Arquivo $subjectrule é igual ao $subjectdownloaded nenhuma ação foi tomada"
    fi
    CopyFiles2
}

#Função responsavel por comparar os arquivos baixados com os atualmente ultilizados
comparatefile() {
    diff --brief $subjectdownloaded $subjectrule >/dev/null
    subjectvalue=$?
    diff --brief $bodydownloaded $bodyrule >/dev/null
    bodyvalue=$?
    CopyFiles
}

#Função responsavel por efetuar a checagem da existencia dos arquivos
CheckBody() {
    if [ -f "$bodyrule" ]; then
        echo "O arquivo $bodyrule existe"
    else
        echo "O arquivo $bodyrule não existe, criando o arquivo"
        echo ""
        touch $bodyrule
        echo "Arquivo $bodyrule criado"
    fi    
    comparatefile
}

#Função responsavel por efetuar a checagem da existencia dos arquivos
CheckSub() {
    if [ -f "$subjectrule" ]; then
        echo "O arquivo $subjectrule existe, prosseguindo com a checagem do arquivo $bodyrule"
    else
        echo "O arquivo $subjectrule não existe, criando o arquivo"
        echo ""
        touch $subjectrule
        echo "Arquivo $subjectrule criado, prosseguindo com a checagem do arquivo $bodyrule"
    fi
    CheckBody
}

#Função Inicial!
FuncInicial(){
    echo "" > $log
    if [ -f "$getfile" ]; then
        echo "existe"
    else
        yum install wget -y
    fi    
    echo "Iniciando atualização das regras anti-spam"
    echo ""
    echo "Iniciando download do arquivo de regras no assunto"
    wget $paramwget $wgetsubject
    echo ""
    echo "Download finalizado"
    echo "Iniciando download do arquivo de regras no corpo"
    wget $paramwget $wgetbody
    echo ""
    echo "Download finalizado"
    echo ""
    echo "Verificando se $subjectrule existe"
    CheckSub 
}

FuncInicial 2>&1 | Log "$@"