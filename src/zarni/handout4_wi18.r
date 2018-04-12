require(foreign)
require(cluster)
require(mclust)


mm <- read.dta(file="simNagin.dta")
matplot(t(mm[,13:22]),type='l',col=1,pch=1,xlab='Time',ylab='Outcome')
mcl <- Mclust(mm[,13:22])
plot(mcl,dim=1:5)
plot(mcl,dim=c(5,10))
matplot(t(mm[,13:22]),type='l',col=(c(4,2,3))[mcl$class],pch=1,xlab='Time',ylab='Outcome')
plot(mcl,data=mm[,c(13:22)],dimen=c(5,10))


#nagin-like fit:
require(lcmm)
simNagin.long <- reshape(mm[,c(1,2,13:22)], varying=c("Y1","Y2","Y3","Y4","Y5","Y6","Y7","Y8","Y9","Y10"), v.names='Y',timevar="Time",idvar="ID",direction="long")
simNagin.long <- simNagin.long[order(simNagin.long$ID,simNagin.long$Time),]
fit.nagin.re <- hlme(Y~Time+I(Time^2),mixture=~Time+I(Time^2), classmb=~1, random=~1,subject='ID',ng=3, data=simNagin.long)
plot(fit.nagin.re,which='fit',var.time='Time',legend=NULL)

#not elegant, but closer to Nagin:
fit.nagin.lm <- flexmix(Y~Time+I(Time^2)|ID,k=3,
model=list(FLXMRglm(Y~., family="gaussian")),data=simNagin.long)
print(lapply(fit.nagin.lm@components,"[[",1))


set.seed(2011)

dat <- read.xport("psychResp1.xpt")
datG <- read.xport('pGroups3.xpt')
matplot(t(dat[,6:9]),type='l',col=c(2:4)[datG$GROUP],lty=1,xlab='Time',ylab='Outcome')

x <- 1:4
fx <- matrix(c(2.567,.058,3.240,-0.024,3.622,0.030),2,3)
mns <- cbind(1,x)%*%fx
matplot(x,mns,type='l',col=2:4,xlab='time',ylab='Resp',ylim=c(2.2,4.2))
matlines(x,t(t(mns)+1*c(.397,.167,.00003)),col=2:4,lty=c(2,4,8))
matlines(x,t(t(mns)-1*c(.397,.167,.00003)),col=2:4,lty=c(2,4,8))
matlines(x,mns,col=2:4,lty=1,lwd=c(5.3,3.3,1.4))
#sim realizations
sigEp<-.302
set.seed(2011)
N <- 104
chs <- rmultinom(N,1,c(.535,.326,.139))
mnsAll <- mns%*%chs
alphas <- rnorm(N)*(c(.397,.167,.00003)%*%chs) 
eps <- rnorm(N*4,sd=sigEp)	
resp <- t(t(mnsAll) + as.numeric(alphas)) + eps
cols <- c(2:4)%*%chs
matplot(x,resp,type='l',col=cols,xlab='time',ylab='Resp')

##supplemental: switching regression?
des.mat <- function(changePt,x) {
    X <- cbind(1,x,1,x)
    X[x<changePt,3:4] <-0
    X[x>=changePt,1:2] <- 0
    X
}
llik <- function(par,y,x,verbose=F) {
    changePt <- par[1]
    sigma <- exp(par[2]) # keep it positive.
    beta <- par[-(1:2)]
    X <- des.mat(changePt,x)
    yhat <- X%*%beta
    if (verbose) {
        ord <- order(x)
        lines(x[ord],yhat[ord],col=sample(2:7))
    }
    sum(dnorm(y-yhat,sd=sigma,log=T))
}
set.seed(101)
x <- rnorm(200)
eps <- rnorm(200)
y <- eps #placeholder
y[x<0] <- 0+1*x[x<0]+eps[x<0]
y[x>=0] <- 2+2*x[x>=0]+eps[x>=0]
plot(x,y)

fit <- optim(par=c(.5,.5,1,1,1,1), fn=llik,x=x,y=y,control=list(fnscale=-1,maxit=2500))
pars <- fit$par
pars[2] <- exp(pars[2])
round(pars[1:2],2)
round(pars[3:4],2)
round(pars[5:6],2)

fit <- optim(par=c(.5,.5,1,1,1,1), fn=llik,x=x,y=y,verbose=T,control=list(fnscale=-1,maxit=1000))
points(x,y)





