locals {
  app_name = "opengatellm"
  region   = "fr-par"
}

resource "scaleway_vpc_private_network" "pn_priv" {
  name = local.app_name
}

resource "scaleway_k8s_cluster" "cluster" {
  name                        = local.app_name
  version                     = "1.32.3"
  cni                         = "cilium"
  private_network_id          = scaleway_vpc_private_network.pn_priv.id
  delete_additional_resources = true
  region                      = local.region
  type                        = "kapsule"
}

resource "scaleway_k8s_pool" "pool-gpu" {
  cluster_id             = scaleway_k8s_cluster.cluster.id
  name                   = "gpu"
  node_type              = "H100-1-80G"
  size                   = 1
  autohealing            = true
  autoscaling            = false
  root_volume_size_in_gb = 250
  region                 = scaleway_k8s_cluster.cluster.region
  zone                   = "${scaleway_k8s_cluster.cluster.region}-2"
  wait_for_pool_ready    = true
}

resource "scaleway_k8s_pool" "pool-cpu-ram" {
  cluster_id             = scaleway_k8s_cluster.cluster.id
  name                   = "cpu-ram"
  node_type              = "pro2-s"
  size                   = 3
  min_size               = 1
  autohealing            = true
  autoscaling            = false
  root_volume_size_in_gb = 30
  region                 = scaleway_k8s_cluster.cluster.region
  zone                   = "${scaleway_k8s_cluster.cluster.region}-1"
  wait_for_pool_ready    = true
}