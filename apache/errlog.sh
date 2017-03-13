#!/bin/bash
(echo -n $1; cat) > /proc/1/fd/2
