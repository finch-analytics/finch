use std::{net::IpAddr, process::Command};

#[derive(Debug, PartialEq, Eq)]
pub struct SparkSubmitClient {
    local_ip: IpAddr,
    master_address: String,
}

impl SparkSubmitClient {
    pub fn new(local_ip: IpAddr, master_address: String) -> Self {
        Self {
            local_ip,
            master_address,
        }
    }

    fn to_cmd(&self) -> Command {
        let mut cmd = Command::new("spark-submit");
        cmd.env("SPARK_LOCAL_IP", self.local_ip.to_string())
            .args(["--master", &self.master_address]);

        cmd
    }
}

#[cfg(test)]
mod tests {
    use std::{ffi::OsStr, net::Ipv4Addr, str::FromStr};

    use super::*;

    fn create_default_client() -> SparkSubmitClient {
        SparkSubmitClient::new(
            IpAddr::V4(
                Ipv4Addr::from_str("10.10.42.2")
                    .expect("Creating ip from string should not fail in tests"),
            ),
            "spark://10.10.42.1:7077".to_owned(),
        )
    }

    #[test]
    fn spark_submit_client_new() {
        let client = create_default_client();

        assert_eq!(
            client,
            SparkSubmitClient {
                local_ip: IpAddr::V4(Ipv4Addr::new(10, 10, 42, 2)),
                master_address: "spark://10.10.42.1:7077".to_owned(),
            }
        )
    }

    #[test]
    fn spark_submit_client_to_cmd() {
        let client = create_default_client();

        let cmd = client.to_cmd();

        assert_eq!(cmd.get_program(), "spark-submit");
        assert_eq!(
            cmd.get_args().collect::<Vec<_>>(),
            &["--master", "spark://10.10.42.1:7077"]
        );
        assert!(cmd
            .get_envs()
            .collect::<Vec<_>>()
            .contains(&(OsStr::new("SPARK_LOCAL_IP"), Some(OsStr::new("10.10.42.2")))));
    }
}
