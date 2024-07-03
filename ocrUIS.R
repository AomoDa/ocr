# UI
oUI <- function(id="iocr", label = "请选择文件") {
  ns <- NS(id)
  tabItem(tabName = "ocr",height=1200,

          box(
              title = "文件", solidHeader = TRUE,width=8,height=150,
              fileInput(inputId = ns("ocr_file"),label = "请上传「发票」文件，支持图片和压缩包"),
          ),
          box(title="下载",width=4,height=150,
              downloadButton(outputId = ns("download"),label = "点击下载数据")
          ),
          box(title="数据",width=12,
              tableOutput(ns("tb_rlt"))
          )
  )
}


# Server
oServer <- function(id="iocr") {
  moduleServer(
    id,
    function(input, output, session) {

    # 处理数据      
    getocrData <- reactive({
      if(is.null(input$ocr_file$datapath)){
        return(NULL)
      }else{
        return(getResult(input$ocr_file$datapath))
      }
    })  

    # 发票下载
    output$download <- downloadHandler(
          filename = function() {
              paste("Invoice_OCR-", Sys.Date(), ".xlsx", sep="")
          },
          content = function(file) {
              write_xlsx(list("OCR_RESULT"=getocrData()),path = file)}
            ) 

    output$tb_rlt <- renderTable(getocrData())


    }
  )
}