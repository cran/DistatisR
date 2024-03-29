# Preamble ----
#_____________________________________________________________________
# distatis: function distatis
# Private functions used in this file
#  >>> See file names matching the function names
# -- private functions
#   o DblCenterDist 
#   o Dist2CP       
#   o MFAnormCP
#   o CP2MFAnormedCP
#   o GetCmat
#   o ComputeSplus
#   o rdiag & ldiag
#________________________
# Last update  08 / 22 / 2020 by Hervé
#_____________________________________________________________________
# distatis Preamble ----
#'  3-Way MDS based on the  "STATIS" optimization
#' procedure.
#'
#'@description
#'  \code{distatis}: Implements the \acronym{DISTATIS}
#'  method which is a 3-way generalization of
#' metric multidimensional scaling
#' (\emph{a.k.a.} classical MDS or principal coordinate analysis).
#' 
#'@details 
#' \code{distatis} takes
#' as input a set of \eqn{K} distance matrices
#' (or  positive semi-definite matrices such as scalar products,
#' covariance, or correlation matrices)
#'  describing a set of \eqn{I} observations.
#' From this set of matrices \code{distatis}    
#' computes: (1) a set of
#' factor scores that describes the similarity structure 
#' of the \eqn{K} distance
#' matrices (e.g., what distance matrices describe the 
#' observations in the same
#' way, what distance matrices differ from each other) 
#' (2) a set of factor
#' scores (called the \emph{compromise} factor scores) 
#' that best describes  
#'  the similarity structure of the \eqn{I} observations 
#' and (3)
#' \eqn{I}
#' sets of
#' partial factor scores that show how 
#' each individual distance matrix "sees"
#' the compromise space.  
#' 
#' \code{distatis} computes the compromise as an optimum
#' linear combination of the cross-product matrices 
#' associated to each distance 
#' (or positive positive semi-definite)
#' matrix. 
#' 
#' \code{distatis} can also be applied to a set of 
#' scalar products, covariance, or correlation
#'  matrices.
#'
#' \acronym{DISTATIS} is part of the 
#' \acronym{STATIS} family.
#' It is often used to analyze
#'  the results of sorting tasks.
#'
#' @aliases distatis DiSTATIS CovSTATIS covstatis
#' @param LeCube2Distance an "observations 
#' \eqn{\times}{*} observations
#' \eqn{\times}{*} distance matrices" array of dimensions
#' \eqn{I\times I \times  K}{I*I*K}.
#' Each of the \eqn{K} "slices" is a \eqn{I\times I}{I*I} square
#' distance (or covariance) matrix describing the 
#' \eqn{I} observations.
#' @param Norm Type of normalization 
#' used for each cross-product matrix derived
#' from the distance (or covariance) matrices.  
#' Current options are \code{NONE}
#' (do nothing), \code{SUMPCA} (normalize by the total inertia) 
#' or \code{MFA} (\code{default}) that normalizes each matrix so
#' that its first eigenvalue is equal to one
#' or \code{NUCLEAR} (i.e., the of the squarae root of the
#' eigenvalues).
#' @param Distance if \code{TRUE} (\code{default}) 
#' the matrices are distance matrices, \code{FALSE}
#' the matrices are treated as positive semi-definite matrices
#' (e.g., scalar products,
#' covariance, or correlation matrices).
#' @param double_centering if \code{TRUE} 
#' (\code{default}) the matrices are double-centered
#' (should always be used for distances).
#' if \code{FALSE} the matrices
#' will \emph{not} be double centered 
#' (note that these matrices 
#' should be semi positive definite matrices such as,
#' for example,
#' covariance matrices).
#' @param RV if \code{TRUE} (\code{default}) 
#' we use the \eqn{R_V}{Rv} coefficient to
#' compute the \eqn{\alpha}{weights}, 
#' if \code{FALSE}
#' we use the matrix scalar product.
#' @param nfact2keep (default: \code{3}) Number of factors 
#' to keep for the computation of the
#' factor scores of the observations.
#' @param compact if \code{FALSE} (default),
#'  \code{distatis} provides detailed output, if
#'  \code{TRUE},  \code{distatis} sends back
#' only the \eqn{\alpha}{alpha} weights
#'  (this option is used to make the
#' bootstrap routine 
#' \code{\link{BootFromCompromise}} more 
#' computationally efficient).
#' @return \code{distatis} sends back the results 
#' \emph{via} two lists:
#' \code{res.Cmat}
#' and \code{res.Splus}.
#' Note that items with a * are the only ones sent back
#' when using the \code{compact = TRUE} option.
#' 
#' \item{res.Cmat}{Results for the between 
#'           distance matrices analysis.}
#' \itemize{ 
#'   \item \code{res.Cmat$C}
#'   The \eqn{I\times I}{I*I} \bold{C} matrix
#'   of scalar products (or \eqn{R_V}{Rv} between distance matrices).  
#'   \item
#'   \code{res.Cmat$vectors} The eigenvectors of the \bold{C} matrix 
#'   \item
#'  \code{res.Cmat$alpha} * The \eqn{\alpha}{alpha} weights 
#'  \item
#'  \code{res.Cmat$value} The eigenvalues of the \bold{C} matrix 
#'  \item
#'  \code{res.Cmat$G} The factor scores for the \bold{C} matrix 
#'  \item 
#'   \code{res.Cmat$ctr} The contributions for \code{res.Cmat$G},
#'  \item
#'    \code{res.Cmat$cos2} The squared cosines for \code{res.Cmat$G}
#'  \item
#'  \code{res.Cmat$d2} The squared 
#'  Euclidean distance  for \code{res.Cmat$G}.
#'    }
#'    
#' \item{res.Splus}{Results for the between observation analysis.}
#' \itemize{
#' \item \code{res.Splus$SCP} an \eqn{I\times I\times K}{I*I*K} array.
#' Contains
#' the (normalized if needed)
#' cross product matrices corresponding to the
#' distance matrices.
#' \item \code{res.Splus$Splus} * The compromise 
#' (optimal linear
#' combination of the SCP's').
#'  \item \code{res.Splus$eigValues} *
#'   The eigenvalues of the compromise).
#'  \item \code{res.Splus$eigVectors} *
#'   The eigenvectors of the compromise).
#' \item \code{res.Splus$tau} * The percentage
#' of explained inertia of the eigenValues).
#' \item \code{res.Splus$ProjectionMatrix} The
#' projection matrix used to compute factor
#' scores and partial factor scores.
#' \item \code{res.Splus$F} The factor scores for the observations.
#'  \item 
#'   \code{res.Splus$ctr} The contributions for \code{res.Cmat$F}.
#'  \item
#'    \code{res.Splus$cos2} The squared cosines for \code{res.Cmat$F}.
#'  \item
#'  \code{res.Splust$d2} The squared 
#'  Euclidean distance  for \code{res.Cmat$F}.
#' \item \code{res.Splus$PartialF} an
#' \eqn{I \times \code{nf2keep} \times K}{I*nf2keep*K} array.
#' Contains the partial factors for the distance
#' matrices.}
#' @author Hervé Abdi
#' #@seealso \code{\link{GraphDistatisAll}} 
#' \code{\link{GraphDistatisBoot}}
#' #\code{\link{GraphDistatisCompromise}} 
#' # \code{\link{GraphDistatisPartial}}
#' #\code{\link{GraphDistatisRv}} \code{\link{DistanceFromSort}}
#' #\code{\link{BootFactorScores}} \code{\link{BootFromCompromise}}
#' #as \code{\link{help}},
#' @references Abdi, H., Valentin, D., O'Toole, A.J., & Edelman, B.
#'  (2005).
#' DISTATIS: The analysis of multiple distance matrices.  
#' \emph{Proceedings of
#' the IEEE Computer Society: 
#' International Conference on Computer Vision and
#' Pattern Recognition}.  (San Diego, CA, USA). pp. 42--47.
#'
#' Abdi, H., Valentin, D., Chollet, S., & Chrea, C. (2007). 
#'  Analyzing
#' assessors and products in sorting tasks:
#'  DISTATIS, theory and applications.
#' \emph{Food Quality and Preference}, \bold{18}, 627--640.
#'
#' Abdi, H., Dunlop, J.P., & Williams, L.J. (2009).  
#' How to compute reliability
#' estimates and display confidence and tolerance 
#' intervals for pattern
#' classifiers using the Bootstrap and 3-way multidimensional scaling
#' (DISTATIS).  
#' \emph{NeuroImage}, \bold{45}, 89--95.
#'
#' Abdi, H., Williams, L.J., Valentin, D., & 
#' Bennani-Dosse, M. (2012).
#'   STATIS
#' and DISTATIS: Optimum multi-table principal component 
#' analysis and three way
#' metric multidimensional scaling.  
#' \emph{Wiley Interdisciplinary Reviews:
#' Computational Statistics}, \bold{4}, 124--167.
#'
#' The \eqn{R_V} coefficient is described in
#'
#' Abdi, H. (2007). RV coefficient and congruence coefficient. 
#'  In N.J. Salkind
#' (Ed.): \emph{Encyclopedia of Measurement and Statistics}.  
#' Thousand Oaks
#' (CA): Sage. pp. 849--853.
#'
#' Abdi, H. (2010). Congruence: Congruence coefficient, 
#' RV coefficient, and
#' Mantel Coefficient.  In N.J. Salkind, D.M., Dougherty,
#'  & B. Frey (Eds.):
#' \emph{Encyclopedia of Research Design.}
#'  Thousand Oaks (CA): Sage. pp.
#' 222--229.
#'
#' (These papers are available from 
#'  \url{https://personal.utdallas.edu/~herve/})
#' @keywords distatis mds DISTATIS MDS
#' @examples
#'
#' # 1. Load the DistAlgo data set 
#' # (available from the DistatisR package).
#' data(DistAlgo)
#' # DistAlgo is a 6*6*4 Array (face*face*Algorithm)
#' #------------------------------------------------------------------
#' # 2. Call the DISTATIS routine with the array 
#' #  of distance (DistAlgo) as parameter
#' DistatisAlgo <- distatis(DistAlgo)
#' @export
distatis <- function(LeCube2Distance,
                     Norm = 'MFA',
                     Distance = TRUE,
                     double_centering = TRUE, 
                     RV = TRUE,
                     nfact2keep = 3,
                     compact = FALSE) {
  # DISTATIS
  # Implements the standard DISTATIS program as
  # described in Abdi H. et al, 2005, 2007, 2009, & 2012.
  # (References to be completed)
  # The compact option is used for the bootstrap
  
  if (Distance & !double_centering){
    stop("You must double center distance matrices !")
  }
  # Transform the cube of distances into a cube of Cross-Products
  # if Distance is already a covariance or correlation, reverse the sign
  CP3 <- LeCube2Distance
  ### ADD test of SDPness?
  # if (Distance != TRUE) { removed because of the default normalization
  #   CP3 <- - CP3
  # }
  # double center ----
  if (double_centering) {
    if (Distance) CP3 <- Dist2CP(CP3)
    else CP3 <- Dist2CP(-CP3)
  }
  # perform MFA normalization ----
  if (Norm == 'MFA') {
    CP3 <- CP2MFAnormedCP(CP3)
  } else if (Norm == 'SUMPCA') {
    CP3 <- CP2SUMPCAnormedCP(CP3)
  }
  # perform "nuclear"
  if (toupper(Norm) == "NUCLEAR"){
      CP3 <-  CP2NuclearNormedCP(CP3)
  }
  # Maybe more options here in the future)
  # Compute the C matrix as an RV matrix
  # Compute C matrix ----
  C <- GetCmat(CP3, RV = RV) # (to match matlab implementation of distatis)
  # get the RV coefficient mat
  # instead of the scalar product
  
  # eigen of C ----
  eigC <- eigen(C, symmetric = TRUE) # Eigen-decomposition of C
  
  if (compact == FALSE) {
    # All C stuff ----
    eigC$vectors[, 1] <- abs(eigC$vectors[, 1])
    rownames(eigC$vectors) <- rownames(C)
    nfC <- ncol(eigC$vectors) # number of eigenvectors of C
    Nom2Dim <- paste('dim', 1:nfC)
    colnames(eigC$vectors) <- Nom2Dim
    # make sure that first eigenvector is positive
    eigC$tau <- round(100 * (eigC$values / sum(eigC$values)))
    names(eigC$tau)    <- Nom2Dim
    names(eigC$values) <- Nom2Dim
    # factors scores for RV mat
    eigC$G   <- t(apply(eigC$vectors, 1, '*', t(t(sqrt(abs(eigC$values) )))))
    rownames(eigC$G) <- rownames(C)
    colnames(eigC$G) <- Nom2Dim
    G2        <- eigC$G^2
   # new C stuff ----
    eigC$ctr  <- rdiag(G2, 1/eigC$values)  
    eigC$d2G  <- rowSums(G2)
    eigC$cos2 <- ldiag(1/eigC$d2G, G2) 
  }
  # alpha weights ----
  alpha <- eigC$vectors[, 1] / sum(eigC$vectors[, 1])
  # compute compromise ----
  Splus <- ComputeSplus(CP3, alpha)
  if (compact == FALSE) {
    # S+ stuff ----
    # eigen of S+ ----
    # Eigen decomposition of Splus
    eigenSplus <- eigen(Splus, symmetric = TRUE)
    # Percent Of Inertia
    eigenSplus$tau <- round(100 * 
                         eigenSplus$values / sum(eigenSplus$values))
    # singular values
    eigenSplus$SingularValues <- sqrt(abs(eigenSplus$values))
    # Get the factor scores (ugly way, but works)
    F <- t(apply(eigenSplus$vectors, 1, '*', t(t(
                                eigenSplus$SingularValues ))))
    rownames(F) <- rownames(Splus)
    # Add on ctr + cos.
    # new S stuff----
    F2     <-  F^2
    d2F    <-  rowSums(F2)
    ctrF   <- rdiag(F2, 1/ abs(eigenSplus$values) )
    cos2F  <- ldiag(1/d2F, F2)
    # Keep only the interesting factors
    Nom2Factors <- paste('Factor', 1:nfact2keep)
    F <- F[, 1:nfact2keep]
    colnames(F) <- Nom2Factors
    ctrF            <- ctrF[, 1:nfact2keep]
    colnames(ctrF)  <- Nom2Factors
    cos2F           <- cos2F[, 1:nfact2keep] 
    colnames(cos2F) <- Nom2Factors
    # Projection matrix ----
    ProjMat <- t(apply(eigenSplus$vectors, 1, '*', 
                       1 / t(t(eigenSplus$SingularValues))))
    Proj <- ProjMat[, 1:nfact2keep]
    colnames(Proj) <- Nom2Factors
    rownames(Proj) <- rownames(Splus)
    # Get the partial projections
    # PartialF ----
    PartialF <- array(apply(CP3, 3, '%*%', Proj),
                      dim = c(dim(CP3)[1], nfact2keep, dim(CP3)[3]))
    rownames(PartialF) <- rownames(Splus)
    colnames(PartialF) <- Nom2Factors
    dimnames(PartialF)[[3]] <- rownames(C)
    
    # pack up the information to send back.
    # May try as some point to keep a structure similar 
    # to MExPosition
    # in the meantime go for fast and match original matlab program.
    # pack return list ----
    res.Cmat <- list(
      C = C,
      eigVector = eigC$vector,
      eigValues = eigC$values,
      tau = eigC$tau,
      G = eigC$G,
      ctr  = eigC$ctr,
      cos2 = eigC$cos2,
      d2   = eigC$d2G,
      alpha = alpha,
      compact = compact
    )
    class(res.Cmat) <- c("Cmat", "list")
    res.Splus <- list(
      SCP = CP3,
      eigValues  = eigenSplus$values,
      eigVectors = eigenSplus$vectors,
      tau   = eigenSplus$tau,
      F = F,
      ctr = ctrF,
      cos2 = cos2F,
      d2 = d2F,
      PartialF = PartialF,
      ProjectionMatrix = Proj,
      Splus = Splus,
      compact = compact
    )
    class(res.Splus) <- c("Splus", "list")
    res.distatis <- list(res4Cmat = res.Cmat,
                         res4Splus = res.Splus,
                         compact = compact,
                         params = list(
                           double_centering = double_centering,
                                       Norm = Norm,
                                       Distance = Distance,
                                       RV = RV))
    class(res.distatis) <- c("DistatisR", "list")
    # End of if compact == FALSE
  } else {
    # When "compact" is TRUE, send back only the compact information
    res.Cmat <- list(alpha = alpha, compact = compact)
    class(res.Cmat) <- c("Cmat", "list")
    res.Splus <- list(Splus = Splus, compact = compact)
    class(res.Splus) <- c("Splus", "list")
    res.distatis <- list(res4Cmat = res.Cmat,
                         res4Splus = res.Splus,
                         compact = compact)
    class(res.distatis) <- c("DistatisR", "list")
  }
  # return ----
  return(res.distatis) # et voila ----
}
# End of File ----