**This is the source code of the paper "Pan Z, Wang Y, Pan Y. A new locally adaptive k-nearest neighbor algorithm based on discrimination class[J]. Knowledge-Based Systems, 2020, 204: 106185."  
**Author: Yikun Wang
**Date: 2024/5/16
**Version: 1.0

-----------------------
Files description:
-----------------------

     1. pro_improve2.m

	Function description: 

                	With this function, we select the discrimination class, and then we get adaptive k based on the ratio and local distribution of discrimination class.

	Parameter setting:

		theta is set as 2.5

	Input description:

		"fold": the number of cross-validations

		"kmax": the range of k values

	Output description:

		"e": the classification error rate

		"k_select": the cumulative percentage of different k values that are chosen as adaptive k 


      2. main.m

	Function description: 

                	This function helps to import data, give the number of categories of the used dataset, and call the function of "pro_improve2".
		
		An example is also given in this function.

	Input description:

		This is the main function so there is no input parameter.

	Output description:

		"e": the classification error rate

		"k_select": the cumulative percentage of different k values that are chosen as adaptive k 


      3. Example

	This folder provides an example of this paper.

	Use "load" function to import data, including the original data downloaded from UCI dataset.

                Output description:

                	"e": the classification error rate

		"k_select":each row represents the cumulative percentage of different k values that are chosen as adaptive k


      4. Dataset used in this paper

	URL: https://www.semanticscholar.org/paper/UCI-Repository-of-machine-learning-databases-Blake/e068be31ded63600aea068eacd12931efd2a1029#account-menu

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

We hope this project can be helpful for your work or study. If you have any suggestions or feedback, please feel free to contact us.

Contact information:

	e-mail: zbpan@xjtu.edu.cn