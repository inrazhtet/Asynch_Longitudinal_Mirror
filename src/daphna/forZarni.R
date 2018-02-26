# Generate some data, ID, Time, Media/BMI (one in x, one in y)
x = cbind(c(rep(1, 5), rep(2, 5)), rep(seq(2,10, by = 2),2), rnorm(10))
y = cbind(c(rep(1,5), rep(2,5)), rep(seq(1, 9, by = 2),2), rnorm(10))

# Expand columns
y = cbind(y[,c(1,2)], NA, y[,3])
x = cbind(x, NA)

# Merge two datasets
w = rbind(x, y)

# Put in order by ID
# ZH: BRILLIANT!
w = w[order(w[,1]),]

# Split by ID
s = split(w, w[,1])
new_s = lapply(s, function(x) matrix(x, ncol = 4, byrow = F))

# Order within ID
ordered = lapply(new_s, function(x) x[order(x[,2]),])

### FILL IN STEP HERE WHERE YOU INTERPOLATE FOR EACH ID
## Here you need to write a function that you will lapply to "ordered" that interpolates all the values. The hard part is your data is much more complex than mine is. This is where I want you to focus your time. 


# Merge data back together
# ZH: Look to see if there is a function that can merge back data without 
# for loops!
data = ordered[[1]]
for(i in 2:length(ordered))
	data = rbind(data, ordered[[i]])


