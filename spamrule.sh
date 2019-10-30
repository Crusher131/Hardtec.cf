log="/var/log/spamrule.log"
subjectrule="/etc/mail/spamassassin/HardtecSubject.cf"
bodyrule="/etc/mail/spamassassin/HardtecBody.cf"
service=MailScanner
subjectdownloaded="/tmp/HardtecSubject.cf"
bodydownloaded="/tmp/HardtecBody.cf"
gitsubject="https://raw.githubusercontent.com/Crusher131/Hardtec.cf/master/HardtecSubject.cf"
gitbody="https://raw.githubusercontent.com/Crusher131/Hardtec.cf/master/HardtecBody.cf"
retorno=0

Log(){
    if [ -z "$1" ]; then
        cat
    else
        printf '%s\n' "$@" 
    fi | tee -a "$log"
}

CheckFiles() {
    if [ -f $subjectrule ]; then
echo "O arquivo $subjectrule existe"
else
echo "O arquivo $subjectrule não existe"
echo "Criando o arquivo $subjectrule"
touch $subjectrule
retorno=$?
echo $retorno
fi
}

FuncInicial(){
echo "Iniciando atualização das regras anti-spam"
echo ""
echo "Iniciando download do arquivo de regras no assunto"
wget --directory-prefix=/tmp/ $gitsubject -q --show-progress --no-check-certificate
echo ""
echo "Download finalizado"
echo "Iniciando download do arquivo de regras no corpo"
wget --directory-prefix=/tmp/ $gitbody -q --show-progress --no-check-certificate 
echo ""
echo "Download finalizado"
echo ""
echo "Verificando se "$subjectrule" existe"
CheckFiles 2>&1 | tee -a $log
}


FuncInicial 2>&1 | Log

