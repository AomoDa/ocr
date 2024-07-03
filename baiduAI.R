library(jsonlite)
library(httr)
library(rvest)

get_access_token <- function() {
	host = 'https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=???&client_secret=???'
	dat = GET(host)  %>% content()
	return(dat$access_token)
}

# token
token <<- get_access_token()

#------------------------------------------------------------------------------------------------
# 增值税发票
#------------------------------------------------------------------------------------------------
getInvoiceInfo <- function(img){
	ps <- unlist(str_split(string = img,pattern = "[.]"))
	pf <- ps[length(ps)]
	if(is.na(img))return(NULL)
	baidu_ai_url = "https://aip.baidubce.com/rest/2.0/ocr/v1/vat_invoice"
	request_url = paste0(baidu_ai_url, "?access_token=",token)
	img_txt <- base64enc::base64encode(img)
	if(pf=="pdf"){ params = list(pdf_file = img_txt)}else{params = list(image = img_txt)}
	dat = POST(request_url, body = params,encode = "form") %>% content()
	rlt = data.frame(
		img = extract_img(img),
		# 发票基本信息
		InvoiceNumConfirm	= dat$words_result$InvoiceNumConfirm,
		InvoiceCode = dat$words_result$InvoiceCode,
		InvoiceDate = dat$words_result$InvoiceDate,
		CheckCode=dat$words_result$CheckCode,
		# 金额
		TotalAmount = dat$words_result$TotalAmount,
		TotalTax = dat$words_result$TotalTax,
		AmountInFiguers = dat$words_result$AmountInFiguers,
		# 销售方
		SellerName = dat$words_result$SellerName,
		SellerRegisterNum =  dat$words_result$SellerRegisterNum,
		SellerBank= dat$words_result$SellerBank,
		# 购买方
		PurchaserName = dat$words_result$PurchaserName,
		PurchaserRegisterNum = dat$words_result$PurchaserRegisterNum,
		CommodityNum = ifelse(length(dat$words_result$CommodityNum)==0,0,dat$words_result$CommodityNum[[1]]$word),
		Remarks = dat$words_result$Remarks,
		stringsAsFactors=FALSE
		)
	return(rlt)
}

# 读取图片，支持ZIP
unzipFile<- function(path) {
	ps <- unlist(str_split(string = path,pattern = "[.]"))
	pf <- ps[length(ps)]
	newpath = "/tmp/ocr/"
	if(pf=="zip"){
		system(paste0("rm -rf ",newpath))
		system(paste0("unzip -o ",path," -d ",newpath))
		system(paste0("rm -rf /tmp/ocr/__MACOSX"))
		path = paste0(newpath,as.vector(na.omit(str_extract(list.files(newpath,recursive=TRUE),".*(png|jpg|jpeg|pdf)"))))
	}
	return(path)
}


# 提取图片名称
extract_img <- function(img) {
	il = unlist(str_split(img,"/|[.]"))
	return(il[length(il)-1])
}

# 批量处理结果 - 增值税发票
getResult <- function(path){
	imgPath = unzipFile(path)
	imgNum = length(imgPath)
	rlt = data.frame()
	for (i in seq_len(imgNum)) {
		ip = imgPath[i]
		cat( as.character(Sys.time())," : ",i,"/",imgNum,"; file = ",ip,"\n")
		tmp = getInvoiceInfo(ip)
		rlt = rbind(tmp,rlt)
	}
	return(rlt)
}


#------------------------------------------------------------------------------------------------
# 完税凭证
#------------------------------------------------------------------------------------------------

getFeeInfo <- function(img){
	ps <- unlist(str_split(string = img,pattern = "[.]"))
	pf <- ps[length(ps)]
	if(is.na(img))return(NULL)
	baidu_ai_url = "https://aip.baidubce.com/rest/2.0/ocr/v1/vat_invoice"
	request_url = paste0(baidu_ai_url, "?access_token=",token)
	img_txt <- base64enc::base64encode(img)
	if(pf=="pdf"){ params = list(pdf_file = img_txt)}else{params = list(image = img_txt)}
	dat = POST(request_url, body = params,encode = "form") %>% content()
	rlt = data.frame(
		img = extract_img(img),

		)
	return(rlt)
}


# 读取图片，支持ZIP
unzipFeeFile<- function(path) {
	ps <- unlist(str_split(string = path,pattern = "[.]"))
	pf <- ps[length(ps)]
	newpath = "/tmp/fee/"
	if(pf=="zip"){
		system(paste0("rm -rf ",newpath))
		system(paste0("unzip -o ",path," -d ",newpath))
		system(paste0("rm -rf /tmp/fee/__MACOSX"))
		path = paste0(newpath,as.vector(na.omit(str_extract(list.files(newpath,recursive=TRUE),".*(png|jpg|jpeg|pdf)"))))
	}
	return(path)
}


# 批量处理结果 - 增值税发票
getFeeResult <- function(path){
	imgPath = unzipFeeFile(path)
	imgNum = length(imgPath)
	rlt = data.frame()
	for (i in seq_len(imgNum)) {
		ip = imgPath[i]
		cat( as.character(Sys.time())," : ",i,"/",imgNum,"; file = ",ip,"\n")
		tmp = getFeeInfo(ip)
		rlt = rbind(tmp,rlt)
	}
	return(rlt)
}