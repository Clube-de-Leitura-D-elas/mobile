function myFunction(e) {
  const SUPABASE_URL = "https://SEU_PROJETO.supabase.co/functions/v1/process-google-form";
  const SUPABASE_ANON_KEY = "SUA_ANON_KEY";

  const mapaPerguntas = {
    "Name": "name",
    "Email": "email",
    "Address": "address",
    "Phone number": "phone_number"
  };

  const respostas = e.response.getItemResponses();
  let payload = {};

  respostas.forEach(resposta => {
    let tituloPerguntaForm = resposta.getItem().getTitle();
    let valorResposta = resposta.getResponse();
    let colunaSupabase = mapaPerguntas[tituloPerguntaForm];
    
    if (colunaSupabase) {
      payload[colunaSupabase] = valorResposta; 
    }
  });

  const options = {
    method: "post",
    contentType: "application/json",
    muteHttpExceptions: true,
    headers: {
      "Authorization": `Bearer ${SUPABASE_ANON_KEY}`,
    },
    payload: JSON.stringify(payload)
  };

  try {
    const respostaAPI = UrlFetchApp.fetch(SUPABASE_URL, options);
    const codigoHTTP = respostaAPI.getResponseCode();
    if (codigoHTTP >= 200 && codigoHTTP < 300) {
      console.log(`✅ Sucesso!`);
    } else {
      console.log(`❌ Erro da API!`);
    }
  } catch (erro) {
    console.log("Erro de execução no Apps Script: " + erro);
  }
}
