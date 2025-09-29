// Author: Daniel Rode
// Created: 10 Dec 2021
// Updated: 22 Nov 2022

// Rewrite of my 5dice Python script in Go. I wanted to compare doing parallel
// processing in Go to what it was like in Python.

// Original description (for Python script): Multithreaded simulation that
// displays the percentage of rolls that 3 came up at least once in each roll.

package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

func cruncher(rolls_per_thread, dice int) int {
	counter := 0
	var rolled_desired_number bool

	for i := 0; i < rolls_per_thread; i++ {
		rolled_desired_number = false
		for j := 0; j < dice; j++ {
			roll := rand.Intn(6) + 1
			// '3' here is chosen arbitrarily (the number could be any number
			// between 1 and 6
			if roll == 3 {
				rolled_desired_number = true
			}
		}
		if rolled_desired_number {
			counter += 1
		}
	}
	return counter
}

func main_alt() {
	workers := 24
	total_rolls := 288000
	rolls_per_thread := total_rolls / workers
	dice := 5

	rand.Seed(time.Now().UnixNano()) // randomize the deterministic rand pool

	var wg sync.WaitGroup
	tally := make(chan int)

	// Spin off parallel workers (routines)
	for i := 0; i < workers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			tally <- cruncher(rolls_per_thread, dice)
		}()
	}

	// Wait for crunching to finish and then cleanup
	// (Note: this way of waiting for all the spun off routines to finish
	// may be specific to needing to read results from a channel. Waiting for
	// background functions to finish which return no data might be handled
	// differently.)
	go func() {
		wg.Wait()
		close(tally)
	}()

	// Calculate and display results
	sum := 0
	for count := range tally {
		sum += count
	}
	fmt.Println(float64(sum) / (float64(workers) * float64(rolls_per_thread)))
}

func main_pure() {
	workers := 16
	total_rolls := 288000
	rolls_per_thread := total_rolls / workers
	dice := 5

	rand.Seed(time.Now().UnixNano()) // randomize the deterministic rand pool

	tally := make(chan int)

	// Spin off parallel workers (routines)
	for i := 0; i < workers; i++ {
		go func() {
			tally <- cruncher(rolls_per_thread, dice)
		}()
	}

	// As each worker finishes, take its tally and add it to the sum
	sum := 0
	for i := 0; i < workers; i++ {
		sum += <-tally
	}

	// Display results
	fmt.Println(float64(sum) / (float64(workers) * float64(rolls_per_thread)))
}

func main() {
	// There are two main functions--'main_alt' and 'main_pure'--that both do
	// the same work, but use different approaches. The 'main_alt' function
	// uses the waitgroup approach to handle an arbitrary number of workers
	// (goroutines); the 'main_pure' function makes do without the use of
	// sync.WaitGroup.

	// main_alt()
	main_pure()
}
