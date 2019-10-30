outlog="/var/log/spamrule.log"
subjectfile="/etc/mail/spamassassin/HardtecSubject.cf"
bodyfile="/etc/mail/spamassassin/HardtecBody.cf"
service=MailScanner
subjectfiled="/tmp/HardtecSubject.cf"
bodyfiled="/tmp/HardtecBody.cf"
gitsub="https://raw.githubusercontent.com/Crusher131/Hardtec.cf/master/HardtecSubject.cf"
gitbody="https://raw.githubusercontent.com/Crusher131/Hardtec.cf/master/HardtecBody.cf"

reinit.mail.func(){
if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
then
service mailscanner restart
else
service MailScanner restart
fi
}

comparate.func(){
    echo "Verificando arquivo baixado e arquivo atual">>$outlog
    diff --brief $subjectfiled $subjectfile >/dev/null
comp_value=$?
if [ $comp_value -eq 1 ]
    then
    comparate2.func
            echo "Arquivos diferentes!">>$outlog
            echo "Subistituindo arquivo atual pelo baixado">>$outlog
                cp -f $subjectfiled $subjectfile 2>&1 |tee -a $outlog
            echo "Reiniciando MailScanner">>$outlog
                reinit.mail.func 2>&1 |tee -a $outlog
            echo "Removendo arquivo Baixado">>$outlog
                rm $subjectfiled 2>&1 |tee -a $outlog
            echo "FIM!">>$outlog
    else
    comparate2.func
        echo "Arquivo baixado e atual são iguais, Sem atualização.">>$outlog
        echo "Removendo arquivo baixado.">>$outlog
            rm $subjectfiled 2>&1 |tee -a $outlog
        echo "FIM!">>$outlog
    fi
}

comparate2.func(){
   diff --brief $bodyfiled $bodyfile >/dev/null
comp_value=$?
if [ $comp_value -eq 1 ]
    then
        echo "Arquivos diferentes!">>$outlog
        echo "Subistituindo arquivo atual pelo baixado">>$outlog
        cp -f $bodyfiled $bodyfile 2>&1 |tee -a $outlog
        reinit.mail.func 2>&1 |tee -a $outlog
    else
        echo "Arquivo baixado e atual são iguais, Sem atualização.">>$outlog
        echo "Removendo arquivo baixado.">>$outlog
fi
}

echo "Iniciando atualização das regras do spamassassin." > $outlog
echo "">>$outlog
echo "Efetuando download do arquivo hardtec.cf">>$outlog
echo "">>$outlog
wget --directory-prefix=/tmp/ $gitsub --no-check-certificate 2>&1 | tee -a $outlog
wget --directory-prefix=/tmp/ $gitbody --no-check-certificate 2>&1 | tee -a $outlog
echo "Download efetuado">>$outlog
echo "" >>$outlog
echo "Verificando se "$subjectfile" existe" >>$outlog
if [ -f $subjectfile ]; then
    echo "O arquivo existe"
    echo "">>$outlog
    if [ -f $bodyfile ]; then
    echo "O arquivo existe"
    echo "">>$outlog
    comparate.func
    else
    echo "">>$outlog
    echo "Criando aruivo">>$outlog
    touch $bodyfile 2>&1 |tee -a $outlog
    comparate.func
fi
    else if [ -f $bodyfile ]; then
    echo "O arquivo existe"
    echo "">>$outlog
    comparate.func
    else
    echo "">>$outlog
    echo "Criando aruivo">>$outlog
    touch $bodyfile 2>&1 |tee -a $outlog
    comparate.func
fi
    
    echo "">>$outlog
    echo "Criando aruivo">>$outlog
    touch $subjectfile 2>&1 |tee -a $outlog
    comparate.func
fi
