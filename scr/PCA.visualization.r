library(gmodels)
library(RColorBrewer)
library(getopt)

command=matrix(c( "datafile" , "d" ,1, "character" ,
                  "minsum" , "m" ,1, "integer" ,
#                  "png" , "p" ,1, "character" ,
                  "help" , "h" ,0, "logical" ),byrow=T,ncol=4)
args=getopt(command)
if  ( ! is.null(args$help) || is.null(args$datafile)) {
     cat(paste(getopt(command, usage = T),  "\n" ))
     q()
}


inname = args$datafile   
minsum = args$minsum

outname <- paste(inname,".pdf",sep="")
table <-  paste(inname,".xls",sep="")
outname
expr <- read.table(inname, header=T, row.names=1)  
colnames(expr)->headers
mycolors <- c()
mykingdoms <-list(
				Archaea="black",
				Bacteria="grey",
				Chromalveolate=brewer.pal(9,"OrRd")[5],
				Fungi=brewer.pal(8,"Dark2")[7],
				Glaucophyta=brewer.pal(8,"Set1")[2],
				Protozoa=brewer.pal(11,"PRGn")[2],
				Rhodophyta=brewer.pal(9,"Set1")[1],
				Viridiplantae=brewer.pal(9,"Greens")[8]
				)

for (d in names(mykingdoms)){
	for (i in grep(d,headers)){
		mycolors[i]<-mykingdoms[[d]]
	}
}

expr[expr>0]<-1
numcol<-ncol(expr)-1
rowSums(expr[,1:numcol])->expr$Total.
subset(expr,expr$Total. > minsum)->expv
expv<-expv[,!grepl("Total.",colnames(expv))]
data <- t(expv)  

#data <- expr


data.pca <- fast.prcomp(data)   
#data.pca <- fast.prcomp(data,retx=T,scale=F,center=T)

a <- summary(data.pca)   
tmp <- a[4]$importance 
pro1 <- as.numeric(sprintf("%.3f",tmp[2,1]))*100 
pro2 <- as.numeric(sprintf("%.3f",tmp[2,2]))*100
xmax <- max(data.pca$x[,1])  
xmin <- min(data.pca$x[,1])
ymax <- max(data.pca$x[,2])
ymin <- min(data.pca$x[,2])
   
samples =rownames(data.pca$x)

pdf(outname)
plot(data.pca$x[,1],data.pca$x[,2],xlab=paste("PC1","(",pro1,"%)",sep=""),ylab=paste("PC2","(",pro2,"%)",sep=""),main="PCA",pch=16,col=mycolors)
abline(h=0,col="gray") 
abline(v=0,col="gray")
text(data.pca$x[,1]-0.6,data.pca$x[,2]+1,labels=samples,cex=0.05)
dev.off()

write.table(data,file=table,sep="",col.names= FALSE)

