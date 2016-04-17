rm(list=ls())
library(data.table)
library(microbenchmark)

# Basic setting ---------------------------
set.seed(100)
N = 5e7L
benchmark_times <- 30


# How to subset a table faster ------------
# Modified from the example given by official vignettes
# https://cran.r-project.org/web/packages/data.table/vignettes/datatable-keys-fast-subset.html


DT <- data.table(x = sample(letters, N, TRUE), 
                y = sample(1000L, N, TRUE), 
                val=runif(N), key = c("x", "y"))
print(object.size(DT), units="Mb")

key(DT)
# [1] "x" "y"

library(microbenchmark)

microbenchmark(ans1 <- DT[x == "g" & y == 877L], 
               ans2 <- DT[.("g", 877L)],
               times = benchmark_times)

identical(ans1$val, ans2$val)
# [1] TRUE




# How to update your table faster---------------
#https://cran.r-project.org/web/packages/data.table/vignettes/datatable-reference-semantics.html

DF <- data.frame(x = sample(letters, N, TRUE), 
                 y = sample(1000L, N, TRUE), 
                 val=runif(N))

DT <- as.data.table(DF)

# Without Key (subsetting involved)
microbenchmark(DF$y[DF$x == "x"] <- 0, 
               DT[x=="x", y := 0], 
               times = benchmark_times)

# without Key (no subsetting involved)
microbenchmark(DF$y <- 0, 
               DT[, y := 0], 
               times = benchmark_times)

# With key (subsetting involved)
setkey(DT, "x") # set the key
microbenchmark(DF$y[DF$x == "x"] <- 0, 
               DT[x=="x", y := 0], 
               DT[.("x"), y := 0],
               DT[.("x"), `:=`(y = 0)],
               times = benchmark_times)

# With key (no subsetting involved)
setkey(DT, "x") # set the key
microbenchmark(DF$y <- 0, 
               DT[, y := 0], 
               DT[, y := 0],
               DT[, `:=`(y = 0)],
               times = benchmark_times)


