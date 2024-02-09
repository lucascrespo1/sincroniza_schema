#!/bin/bash

source ~/.bashrc
export vSchema="SCHEMA"
export vSenha="SENHA"
sqlplus / as sysdba <<EOF
alter user ${vSchema} account lock;
/
shut immediate;
/
startup;
/
drop user ${vSchema} cascade;
/
exit;
EOF

export vOrigemDump="/path/para/dump/origem/"
export vDestinoDump="/path/para/dump/destino/"
export vUser="user"
export vServerOrigem="xxx.xxx.xxx.xxx"
#export vPortaOrigem="xxxxx"
#export vArquivo=$(ssh -p ${vPortaOrigem} ${vUser}@${vServerOrigem} "find ${vOrigemDump} -type f -name '*.dmp.gz*' -printf '%T+ %p\n' | sort -r | head -n1 | cut -d' ' -f2")
export vArquivo=$(ssh ${vUser}@${vServerOrigem} "find ${vOrigemDump} -type f -name '*.dmp*' -printf '%T+ %p\n' | sort -r | head -n1 | cut -d' ' -f2")

#scp -P ${vPortaOrigem} ${vUser}@${vServerOrigem}:${vArquivo} ${vDestinoDump}
scp ${vUser}@${vServerOrigem}:${vArquivo} ${vDestinoDump}
export vArquivoCompacto=$(find ${vDestinoDump} -maxdepth 1 -type f -name "*gz*" -printf "%T@ %p\n" | sort -n | tail -n 1 | cut -d' ' -f2-)
if [[ vArquivoCompacto == *.tar.* ]]
then
	tar -xzf ${vArquivoCompacto}
	rm -rf ${vDestinoDump}*.tar.*
elif [[ vArquivoCompacto == *.zip* ]]
then
	unzip ${vArquivoCompacto}
	rm -rf ${vDestinoDump}*.zip*
elif [[ vArquivoCompacto == *.gz ]]
then
	gzip -d ${vArquivoCompacto}
	rm -rf ${vDestinoDump}*.gz*
else
	continue
fi

export vArquivoDump=$(find ${vDestinoDump} -maxdepth 1 -type f -name "*.dmp" -printf "%T@ %p\n" | sort -n | tail -n 1 | cut -d' ' -f2- | xargs basename)
export vExpCredenciais="xxxx/xxxx"

impdp ${vExpCredenciais} DIRECTORY=BACKUP DUMPFILE=${vArquivoDump} LOGFILE=impdp_automatico.log SCHEMAS=${vSchema} EXCLUDE=STATISTICS

sqlplus / as sysdba <<EOF
@/rdbms/admin/utlrp.sql;
/
alter user ${vSchema} account unlock;
/
alter user ${vSchema} identified by ${vSenha};
/
exit;
EOF

rm -rf ${vDestinoDump}*.dmp*