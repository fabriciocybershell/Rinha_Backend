#! /bin/bash

# código principal para receber, processar e enviar os dados da API da rinha.

# definindo array nomeado para separar informações do header:
declare -A HEAD

# local do log:
LOG="./guardiao/backend.log"

# variáveis padrão:
STATUS="200 - Ok"

# definindo host atual:
declare -A HEAD

# definindo local para registrar o corpo:
BODY_REQUEST=();
# fazendo leitura do buffer de entrada o mais veloz possível:
while IFS= read -t 0.001 -r buffer || [[ -n ${buffer} ]];do
	[[ -n "${buffer}" ]] || break
	BODY_REQUEST+=( "${buffer}" );
done <&0

# meios de debug:
# echo "////////////////////////////////////////////
# ${BODY_REQUEST[@]}" >>"${LOG}"

# requisição completa de solicitação de um arquivo:
# GET /css/styles.css HTTP/1.1 # exemplo de teste de requisição.
[[ "${BODY_REQUEST[*]}" =~ (GET|POST).(\/[^\ ]*).HTTPS?\/([0-9]{1,2}\.[0-9]{1,2}) ]] && {
	# obtendo partes do cabeçalho atravéz dos retrovisores:
	HEAD['METHOD']="${BASH_REMATCH[1]}"
	HEAD['PATH']="${BASH_REMATCH[2]}"
	HEAD['VERSION']="${BASH_REMATCH[3]}"
}

# enviando respósta de exemplo temporária para testes iniciais:

# variável controle:
valid=0

# aqui sei que estes seriam os dados que eu fosse receber, mas estou ajustando para ver a velocidade de respósta com algum dado:

# diferenciar chamadas de API:
[[ "${HEAD['METHOD']}" = "POST" ]] && {
	[[ "${HEAD['PATH']}" = "/payments" ]] && {
		valid=1
		# adicionar meios de envio e registros das transações:

		# variaveis ambientes para chamar os endpoints:
		# PAYMENT_PROCESSOR_URL_DEFAULT e PAYMENT_PROCESSOR_URL_FALLBACK

		# melhor e mais confiável meio de registro local com lock:
		# {
		#   flock -x 3
			# variavel local temporário, será decidido destino posteriormente:
			# destino="default"
			# ler dados de default/fallback:
			# IFS=":" read requests amount <<< "$(< "${destino}.txt")"

			# incrementar valor de requests:
			# requests="$((${requests:-0}+1))"
			# incrementar valor de default/fallback:
			# amount="$(bc --matchlib <<< ${amount//\,/\.})"
		#   printf "${requests}:${amount}" >&3
		# } 3>>"${destino}.txt"

# respósta para testar montagem interna dos containers:
# 		dados="{
#     \"message\" : \"variavel ambiente: ${PAYMENT_PROCESSOR_URL_DEFAULT}\"
# }
# "
# 		echo -ne "HTTP/1.1 ${STATUS}\r\nContent-Type: application/json\r\nContent-Length: ${#dados}\r\n\r\n${dados}\r\n\r\n"
		# emitir respósta padrão em caso se sucesso:
		echo -ne "HTTP/1.1 ${STATUS}\r\n\r\n"
		exit 1
	}
}

# requisições GET:
[[ "${HEAD['METHOD']}" = "GET" ]] && {
	[[ "${HEAD['PATH']}" = "/payments-summary" ]] && {
		valid=1
		# adicionar meios de pesquisa:

		# template para preencher com respósta do DB:
		dados="{
    \"default\" : {
        \"totalRequests\": ${default_requests},
        \"totalAmount\": ${default_amount}
    },
    \"fallback\" : {
        \"totalRequests\": ${fallback_requests},
        \"totalAmount\": ${default_amount}
    }
}
"

		echo -ne "HTTP/1.1 ${STATUS}\r\nContent-Type: application/json\r\nContent-Length: ${#dados}\r\n\r\n${dados}\r\n\r\n"
		exit 1
	}
}

[[ ${valid} -eq 0 ]] && STATUS="404 - Not Found"

echo -ne "HTTP/1.1 ${STATUS}\r\n\r\n"
exit 1

# exemplo para usar como base:
# iniciar operação conforme API com timeout de 100ms:
# timeout
# se encerrou com timeout, marcar flag global para desviar para payment fallback;
# verificar se arquivo específico de payment existe, se existir, ler e verificar tempo, senão, perguntar também.
# consultar dados de fallback e sua disponibilidade, dependendo de qual for, gravar dado mais específico para quando tempo acabar:
# registrar se deu certo:

# APIS e dados de recebimento e retorno:
# POST /payments
# {
#     "correlationId": "4a7901b8-7d26-4d9d-aa19-4dc1c7cf60b3",
#     "amount": 19.90
# }

# HTTP 2XX

# GET /payments-summary?from=2020-07-10T12:34:56.000Z&to=2020-07-10T12:35:56.000Z

# HTTP 200 - Ok
# {
#     "default" : {
#         "totalRequests": 43236,
#         "totalAmount": 415542345.98
#     },
#     "fallback" : {
#         "totalRequests": 423545,
#         "totalAmount": 329347.34
#     }
# }
# requisição

# from é um campo opcional de timestamp no formato ISO em UTC (geralmente 3 horas a frente do horário do Brasil).
# to é um campo opcional de timestamp no formato ISO em UTC.
# resposta

# default.totalRequests é um campo obrigatório do tipo inteiro.
# default.totalAmount é um campo obrigatório do tipo decimal.
# fallback.totalRequests é um campo obrigatório do tipo inteiro.
# fallback.totalAmount é um campo obrigatório do tipo decimal.
