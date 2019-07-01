
# Function "ipak" is a powerful function developed by Yifan Wu, a PhD student from department of 
# statistics and actuarial science. To load all the required packages/library in our analysis, we 
# suggest to run this function at the beginning.


# Function Ipak for Detecting and Installing the Packages
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}


# The list/vector with the name of the packages you need in the further analysis coding.
packages <- c("tidyverse",  # General-purpose data wrangling
              "rvest",  # Parsing of HTML/XML files  
              "stringr",    # String manipulation
              "rebus",      # Verbose regular expressions
              "lubridate",   # Eases DateTime manipulation
              "aRxiv",   # Package for communicating to aRvix.org API and get update information
              "RPostgreSQL", # Package for communicating to PostgreSQL
              "RCurl",   
              "rjson")

# Passing the list/vector of package name to the function to check the installation of the packages
ipak(packages)


# Function for Getting the information of the  n-th papers from the total N newest paper 
get.nth.paper = function(n,N,webpage){
  if (n>N){
    print("Exceeding the limit N, only give the information of the N-th newest paper ")
    n = N}
  
  webpage.local = webpage
  ## Get the Link of the newest paper
  link=webpage.local%>%html_nodes(paste("#dlpage > dl:nth-child(10) > dt:nth-child(",2*n-1,") > span:nth-child(2) > a:nth-child(1)", sep = ""))%>%html_text
  
  link.make = paste("https://arxiv.org/abs/", substr(link,7,nchar(link)),sep = "")
  
  ## Get All the information of the newest paper
  all= webpage.local%>%html_nodes(paste("#dlpage > dl:nth-child(10) > dd:nth-child(",2*n,") > div:nth-child(1)", sep = ""))%>%html_text
  
  all.clean = unlist(strsplit(all,split='\n\n\n', fixed=TRUE))
  
  all.title = substr(all.clean[1],10,nchar(all.clean[1]))
  
  all.author= str_remove_all(substr(all.clean[2],10,nchar(all.clean[2])), "\n")
  
  all.description = str_remove_all(all.clean[length(all.clean)],"\n")
  
  all.final = data.frame(link = link,
                         link_makeup = link.make,
                         title = all.title,
                         author = all.author,
                         description = all.description)
  return(all.final)
}

# Function for checking the number of new submission papers on the website
get.new.num = function(){
  url.full = "https://arxiv.org/list/cs/new"
  webpage.full = read_html(url.full)
  all.papers= webpage.full%>%html_nodes("#dlpage > dl:nth-child(10)")%>%html_text
  all.papers.num = length(unlist(strsplit(all.papers,split='\n\n\n\n[', fixed=TRUE)))
  return(all.papers.num)
}

# Function for getting the information of the first(oldest) N paper 
# from https://arxiv.org/list/cs/new
get.first.N.paper = function(N){
  all.N = data.frame(matrix(ncol = 5, nrow = 1))
  colnames(all.N) <- c("link", "link_makeup", 
                       "title", "author", 
                       "description")
  all.paper.num = get.new.num()
  if (N<=all.paper.num){
    url.local = paste("https://arxiv.org/list/cs/new?skip=0&show=",N,sep="")
    #Reading the HTML code from the website
    webpage.local <- read_html(url.local)
    for (n in 1:N){
      nth.paper = get.nth.paper(n,N,webpage.local)
      all.N = rbind(all.N, nth.paper)
    }
    all.N = all.N[-1,]
    return(all.N)}else{
      print(paste("Total number of paper on this site is only",all.paper.num))
      for (n in 1:all.paper.num){
        nth.paper = get.nth.paper(n,all.paper.num,webpage.local)
        all.N = rbind(all.N, nth.paper)
      }
      all.N = all.N[-1,]
      return(all.N)
    }
}


# Function for getting the information of the latest N paper from 
# https://arxiv.org/list/cs/new
get.last.N.paper = function(N){
  all.N = data.frame(matrix(ncol = 5, nrow = 1))
  colnames(all.N) <- c("link", "link_makeup", 
                       "title", "author", 
                       "description")
  n.new = get.new.num()
  url.full = "https://arxiv.org/list/cs/new"
  webpage.full = read_html(url.full)
  if (N<=n.new){
    for (n in n.new:(n.new-N+1)){
      nth.paper = get.nth.paper(n,n.new,webpage.full)
      all.N = rbind(all.N, nth.paper)
    }
    all.N = all.N[-1,]
    return(all.N)}else{
      print(paste("Total number of paper on this site is only",n.new))
      for (n in n.new:1){
        nth.paper = get.nth.paper(n,n.new,webpage.full)
        all.N = rbind(all.N, nth.paper)
      }
      all.N = all.N[-1,]
      return(all.N)
    }
}


# Function for getting all new submission papers on the website
get.all.paper = function(){
  n.all = get.new.num()
  df.all = get.first.N.paper(n.all)
  return(df.all)
}


# Function for checking the new submission in all new submissions and updating the existed dataframe
get.new.submission = function(new.paper){
  pg <- dbDriver("PostgreSQL")
  con <- dbConnect(pg, host="localhost", user="postgres",password = "aptx0330")
  df.existed.link = dbGetQuery(con, "SELECT link from cs_paper_meta")$link
  paper.new.submit = subset(new.paper, !(new.paper$link %in% df.existed.link))
  if ((nrow(na.omit(paper.new.submit))) != 0){
    dbWriteTable(con,'cs_paper_meta',paper.new.submit, append = TRUE, row.names=FALSE)
  }else{
    print("All the papers from the scrapping are already existed in our database")
  }
  
  dbDisconnect(con)  
}



# Main function for checking the new submission from the first/latest N papers (or all)
main.paper.update = function(n = 50, paper = "latest", all = FALSE){
  if (all == TRUE){
    paper = get.all.paper()
  }else if (paper == "latest"){
    paper = get.last.N.paper(n)
  }else{
    paper = get.first.N.paper(n)
  }
  
  get.new.submission(paper)
}

main.paper.update(n=300)
